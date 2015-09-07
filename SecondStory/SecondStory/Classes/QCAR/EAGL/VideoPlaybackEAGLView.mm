/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <sys/time.h>

#import <QCAR/QCAR.h>
#import <QCAR/State.h>
#import <QCAR/Tool.h>
#import <QCAR/Renderer.h>
#import <QCAR/TrackableResult.h>
#import <QCAR/ImageTarget.h>


#import "VideoPlaybackEAGLView.h"
#import "Texture.h"
#import "SampleApplicationUtils.h"
#import "SampleApplicationShaderUtils.h"
#import "Teapot.h"
#import "SampleMath.h"
#import "Quad.h"

#import "FullScreenVideoControllerViewController.h"
#import "VideoPlaybackViewController.h"



//******************************************************************************
// *** OpenGL ES thread safety ***
//
// OpenGL ES on iOS is not thread safe.  We ensure thread safety by following
// this procedure:
// 1) Create the OpenGL ES context on the main thread.
// 2) Start the QCAR camera, which causes QCAR to locate our EAGLView and start
//    the render thread.
// 3) QCAR calls our renderFrameQCAR method periodically on the render thread.
//    The first time this happens, the defaultFramebuffer does not exist, so it
//    is created with a call to createFramebuffer.  createFramebuffer is called
//    on the main thread in order to safely allocate the OpenGL ES storage,
//    which is shared with the drawable layer.  The render (background) thread
//    is blocked during the call to createFramebuffer, thus ensuring no
//    concurrent use of the OpenGL ES context.
//
//******************************************************************************


namespace {
    // --- Data private to this unit ---
    // Augmentation model scale factor
    const float kObjectScale = 3.0f;
    
    // Texture filenames (an Object3D object is created for each texture)
    const char* textureFilenames[NUM_AUGMENTATION_TEXTURES] = {
        "icon_play.png",
        "icon_loading.png",
        "icon_error.png",
        //"VuforiaSizzleReel_1.png",
        //"VuforiaSizzleReel_2.png"
        /*
        "alley.jpg",
        "beef.jpg",
        "bicycles.jpg",
        "copper.jpg",
        "gun.jpg",
        "pennies.jpg",
        "shrooms.jpg",
        "sweeping.jpg",
        "umbrellas.jpg"
         */
        "amy.jpg",
        "claire.jpg",
        "jess.jpg",
        "kiki.jpg",
        "marci.jpg",
        "mily.jpg",
        "sultan1.jpg",
        "sultan2.jpg"
    };
    
    enum tagObjectIndex {
        OBJECT_PLAY_ICON,
        OBJECT_BUSY_ICON,
        OBJECT_ERROR_ICON,
        OBJECT_KEYFRAME_1,
        OBJECT_KEYFRAME_2,
        OBJECT_KEYFRAME_3,
        OBJECT_KEYFRAME_4,
        OBJECT_KEYFRAME_5,
        OBJECT_KEYFRAME_6,
        OBJECT_KEYFRAME_7,
        OBJECT_KEYFRAME_8,
        OBJECT_KEYFRAME_9,
    };
    
    const NSTimeInterval DOUBLE_TAP_INTERVAL = 0.3f;
    const NSTimeInterval TRACKING_LOST_TIMEOUT = 20.0f;
    
    // Playback icon scale factors
    const float SCALE_ICON = 2.0f;
    const float SCALE_ICON_TRANSLATION = 1.98f;
    
    // Video quad texture coordinates
    const GLfloat videoQuadTextureCoords[] = {
        0.0, 1.0,
        1.0, 1.0,
        1.0, 0.0,
        0.0, 0.0,
    };
    
    struct tagVideoData {
        // Needed to calculate whether a screen tap is inside the target
        QCAR::Matrix44F modelViewMatrix;
        
        // Trackable dimensions
        QCAR::Vec2F targetPositiveDimensions;
        
        // Currently active flag
        BOOL isActive;
    } videoData[1]; // was NUM_VIDEO_TARGETS
    
    int touchedTarget = 0;
}


@interface VideoPlaybackEAGLView (PrivateMethods)

- (void)initShaders;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;

@end


@implementation VideoPlaybackEAGLView

// You must implement this method, which ensures the view's underlying layer is
// of type CAEAGLLayer
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}


//------------------------------------------------------------------------------
#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame rootViewController:(VideoPlaybackViewController *) rootViewController appSession:(SampleApplicationSession *) app
{
    self = [super initWithFrame:frame];
    
    if (self) {
        vapp = app;
        videoPlaybackViewController = rootViewController;
        
        // Enable retina mode if available on this device
        if (YES == [vapp isRetinaDisplay]) {
            [self setContentScaleFactor:2.0f];
        }
        
        // Load the augmentation textures
        for (int i = 0; i < NUM_AUGMENTATION_TEXTURES; ++i) {
            augmentationTexture[i] = [[Texture alloc] initWithImageFile:[NSString stringWithCString:textureFilenames[i] encoding:NSASCIIStringEncoding]];
        }

        // Create the OpenGL ES context
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        if (context == nil) {
            context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        }
        
        // The EAGLContext must be set for each thread that wishes to use it.
        // Set it the first time this method is called (on the main thread)
        if (context != [EAGLContext currentContext]) {
            [EAGLContext setCurrentContext:context];
        }
        
        // Generate the OpenGL ES texture and upload the texture data for use
        // when rendering the augmentation
        for (int i = 0; i < NUM_AUGMENTATION_TEXTURES; ++i) {
            GLuint textureID;
            glGenTextures(1, &textureID);
            [augmentationTexture[i] setTextureID:textureID];
            glBindTexture(GL_TEXTURE_2D, textureID);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [augmentationTexture[i] width], [augmentationTexture[i] height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[augmentationTexture[i] pngData]);
            
            // Set appropriate texture parameters (for NPOT textures)
            if (OBJECT_KEYFRAME_1 <= i) {
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            }
        }

        [self initShaders];
    }
    
    return self;
}

- (void) willPlayVideoFullScreen:(BOOL) fullScreen {
    playVideoFullScreen = fullScreen;
}

- (void) setPaths {
    
    NSString *customPath = @"/SecondStory/BloodAlley/MEDIA";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    LOCAL_MEDIA_PATH = [documentsDirectory stringByAppendingPathComponent:customPath];
    
    REMOTE_MEDIA_PATH = @"http://jesses.co.tt/projects/second_story/blood_alley/media";

    
    // Load PList For Files
    NSString *pathToLocalPlist = [[NSBundle mainBundle] pathForResource:@"bloodalley_filenames_local" ofType:@"plist"];
    localFiles = [[NSArray alloc] initWithContentsOfFile:pathToLocalPlist];
    
    NSString *pathToRemotePlist = [[NSBundle mainBundle] pathForResource:@"bloodalley_filenames_remote" ofType:@"plist"];
    remoteFiles = [[NSArray alloc] initWithContentsOfFile:pathToRemotePlist];
}

- (BOOL) videoIsLocal: (int) index {
    NSError *error;
    NSLog(@"PATH IS %@", LOCAL_MEDIA_PATH);
    NSArray  *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:LOCAL_MEDIA_PATH error:&error];
    NSString *fileNameToMatch = [localFiles objectAtIndex:index];
    BOOL match = NO;
    for (int i = 0; i < [contents count]; i++) {
        //NSLog(@"Item #%i is %@", i, [contents objectAtIndex:i]);
        if ([[contents objectAtIndex:i] isEqualToString:fileNameToMatch]) {
            NSLog(@"MATCH: %@", fileNameToMatch);
            LOCAL_FILE = fileNameToMatch;
            match = YES;
        }
    }
    return match;
}

- (NSString*) returnDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doc = [paths objectAtIndex:0];
    return doc;
}

- (void) setPathForMovie: (int) index {
    
    NSString *customPath = @"/SecondStory/BloodAlley/MEDIA/";
    NSArray *defaultPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [defaultPaths objectAtIndex:0];
    NSString *localDirPath = [documentsDirectory stringByAppendingPathComponent:customPath];
    localDirPath = [localDirPath stringByAppendingString:@"/"];
    NSString *remoteDirPath = @"http://jesses.co.tt/projects/second_story/blood_alley/media/";
    NSString *pathToLocalPlist = [[NSBundle mainBundle] pathForResource:@"bloodalley_filenames_local" ofType:@"plist"];
    localFiles = [[NSArray alloc] initWithContentsOfFile:pathToLocalPlist];
    NSString *filename;
    
    /*
    BOOL isDirectory;
    BOOL dirExistsAtPath = [[NSFileManager defaultManager] fileExistsAtPath:localDirPath isDirectory:&isDirectory];
    if (dirExistsAtPath) {
        if (isDirectory) {
            NSString *fileNameToMatch = [localDirPath stringByAppendingString:[localFiles objectAtIndex:index]];
            BOOL fileExistsAtPath = [[NSFileManager defaultManager] fileExistsAtPath:fileNameToMatch];
            if(fileExistsAtPath) {
                //filename = fileNameToMatch;
                filename = [localFiles objectAtIndex:index];
                NSLog(@"Filename of movie is %@", filename);
            }
            else {
                filename = [remoteDirPath stringByAppendingString:[localFiles objectAtIndex:index]];
            }
        }
        else {
            NSLog(@"NOT A DIR ????");
        }
    }
    */
    
    NSString *mMovieName = @"";
    switch (index) {
            //            case 0: // Beef
            //                mMovieName = MEDIA_PATH + "beef.mp4";
            //                break;
        case 0: // AMY
            mMovieName = @"leaving";
            break;
        case 1: // CLAIRE
            mMovieName = @"exhibita";
            break;
        case 2: // JESS
            mMovieName = @"portability";
            break;
        case 3: // KIKI
            mMovieName = @"stall";
            break;
        case 4: // MARCI
            mMovieName = @"plant";
            break;
        case 5: // MILY
            mMovieName = @"cirque";
            break;
        case 6: // SULTAN1
            mMovieName = @"letter pt2";
            break;
        case 7: // SULTAN2
            mMovieName = @"letter pt2";
            break;
            
        default:
            mMovieName = @"";
    }
    
    

    // Unload & Load Movie
    [singleVideoPlayerHelper unload];
    if (NO == [singleVideoPlayerHelper load:mMovieName playImmediately:NO fromPosition:videoPlaybackTime[0]]) {
        NSLog(@"Failed to load media");
    }
}

- (void) prepareSinglePlayer {
    singleVideoPlayerHelper = [[VideoPlayerHelper alloc] initWithRootViewController:videoPlaybackViewController];
    videoData[SINGLE_HELPER].targetPositiveDimensions.data[0] = 0.0f;
    videoData[SINGLE_HELPER].targetPositiveDimensions.data[1] = 0.0f;
}

- (void) prepare {
    
    // For each target, create a VideoPlayerHelper object and zero the
    // target dimensions
    // For each target, create a VideoPlayerHelper object and zero the
    // target dimensions
    for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        videoPlayerHelper[i] = [[VideoPlayerHelper alloc] initWithRootViewController:videoPlaybackViewController];
        videoData[i].targetPositiveDimensions.data[0] = 0.0f;
        videoData[i].targetPositiveDimensions.data[1] = 0.0f;
    }
    

    
    // Start video playback from the current position (the beginning) on the
    // first run of the app
    for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        videoPlaybackTime[i] = VIDEO_PLAYBACK_CURRENT_POSITION;
    }
    
    // For each video-augmented target
    for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        // Load a local file for playback and resume playback if video was playing when the app went into the background
        VideoPlayerHelper* player = [self getVideoPlayerHelper:i];
        NSString* filename;
        //NSString *file = [LOCAL_MEDIA_PATH stringByAppendingString:@"/"];
        filename = @"VuforiaSizzleReel_2.m4v";
        /*
        switch (i) {
            case 0:
                if([self videoIsLocal:i]) {
                    filename = [file stringByAppendingString:LOCAL_FILE];
                }
            break;
            case 1:
                if([self videoIsLocal:i]) {
                    filename = [file stringByAppendingString:LOCAL_FILE];
                }
                break;
            case 2:
                if([self videoIsLocal:i]) {
                    filename = [file stringByAppendingString:LOCAL_FILE];
                }
                break;
            case 3:
                if([self videoIsLocal:i]) {
                    filename = [file stringByAppendingString:LOCAL_FILE];
                }
                break;
            case 4:
                if([self videoIsLocal:i]) {
                    filename = [file stringByAppendingString:LOCAL_FILE];
                }
                break;
            case 5:
                if([self videoIsLocal:i]) {
                    filename = [file stringByAppendingString:LOCAL_FILE];
                }
                break;
            case 6:
                if([self videoIsLocal:i]) {
                    filename = [file stringByAppendingString:LOCAL_FILE];
                }
                break;
            case 7:
                if([self videoIsLocal:i]) {
                    filename = [file stringByAppendingString:LOCAL_FILE];
                }
                break;
            case 8:
                if([self videoIsLocal:i]) {
                    filename = [file stringByAppendingString:LOCAL_FILE];
                }
                break;
            case 9:
                if([self videoIsLocal:i]) {
                    filename = [file stringByAppendingString:LOCAL_FILE];
                }
                break;
            default:
                filename = @"VuforiaSizzleReel_2.m4v";
            break;
        }
        */
        if (NO == [player load:filename playImmediately:NO fromPosition:videoPlaybackTime[i]]) {
            NSLog(@"Failed to load media");
        }
    }
    
    
}
    
- (void) dismiss {
    for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        [videoPlayerHelper[i] unload];
        [videoPlayerHelper[i] release];
        videoPlayerHelper[i] = nil;
    }
    
    // SINGLE
    [singleVideoPlayerHelper unload];
    [singleVideoPlayerHelper release];
    singleVideoPlayerHelper = nil;
}

- (void)dealloc
{
    [self deleteFramebuffer];
    
    // Tear down context
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];

    for (int i = 0; i < NUM_AUGMENTATION_TEXTURES; ++i) {
        [augmentationTexture[i] release];
    }
    
    for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        [videoPlayerHelper[i] release];
    }
    [super dealloc];
}


- (void)finishOpenGLESCommands
{
    // Called in response to applicationWillResignActive.  The render loop has
    // been stopped, so we now make sure all OpenGL ES commands complete before
    // we (potentially) go into the background
    if (context) {
        [EAGLContext setCurrentContext:context];
        glFinish();
    }
}


- (void)freeOpenGLESResources
{
    // Called in response to applicationDidEnterBackground.  Free easily
    // recreated OpenGL ES resources
    [self deleteFramebuffer];
    glFinish();
}

//------------------------------------------------------------------------------
#pragma mark - User interaction

- (bool) handleTouchPoint:(CGPoint) point {
    // Store the current touch location
    touchLocation_X = point.x;
    touchLocation_Y = point.y;
    
    // Determine which target was touched (if no target was touch, touchedTarget
    // will be -1)
    touchedTarget = [self tapInsideTargetWithID];
    
    // Ignore touches when videoPlayerHelper is playing in fullscreen mode
    if (-1 != touchedTarget && PLAYING_FULLSCREEN != [videoPlayerHelper[touchedTarget] getStatus]) {
        // Get the state of the video player for the target the user touched
        MEDIA_STATE mediaState = [videoPlayerHelper[touchedTarget] getStatus];
        
        // If any on-texture video is playing, pause it
        for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
            if (PLAYING == [videoPlayerHelper[i] getStatus]) {
                [videoPlayerHelper[i] pause];
            }
        }
        
#ifdef EXAMPLE_CODE_REMOTE_FILE
        // With remote files, single tap starts playback using the native player
        if (ERROR != mediaState && NOT_READY != mediaState) {
            // Play the video
            NSLog(@"Playing video with native player");
            [videoPlayerHelper[touchedTarget] play:YES fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
        }
#else
        // For the target the user touched
        if (ERROR != mediaState && NOT_READY != mediaState && PLAYING != mediaState) {
            // Play the video
            NSLog(@"Playing video with on-texture player");
            [videoPlayerHelper[touchedTarget] play:playVideoFullScreen fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
        }
#endif
        return true;
    } else {
        return false;
    }
}

- (void) preparePlayers {
    [self prepare];
}


- (void) dismissPlayers {
    [self dismiss];
}



// Determine whether a screen tap is inside the target
- (int)tapInsideTargetWithID
{
    QCAR::Vec3F intersection, lineStart, lineEnd;
    // Get the current projection matrix
    QCAR::Matrix44F projectionMatrix = [vapp projectionMatrix];
    QCAR::Matrix44F inverseProjMatrix = SampleMath::Matrix44FInverse(projectionMatrix);
    CGRect rect = [self bounds];
    int touchInTarget = -1;
    
    // ----- Synchronise data access -----
    [dataLock lock];
    
    // The target returns as pose the centre of the trackable.  Thus its
    // dimensions go from -width / 2 to width / 2 and from -height / 2 to
    // height / 2.  The following if statement simply checks that the tap is
    // within this range
    for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        SampleMath::projectScreenPointToPlane(inverseProjMatrix, videoData[i].modelViewMatrix, rect.size.width, rect.size.height,
                                              QCAR::Vec2F(touchLocation_X, touchLocation_Y), QCAR::Vec3F(0, 0, 0), QCAR::Vec3F(0, 0, 1), intersection, lineStart, lineEnd);
        
        if ((intersection.data[0] >= -videoData[i].targetPositiveDimensions.data[0]) && (intersection.data[0] <= videoData[i].targetPositiveDimensions.data[0]) &&
            (intersection.data[1] >= -videoData[i].targetPositiveDimensions.data[1]) && (intersection.data[1] <= videoData[i].targetPositiveDimensions.data[1])) {
            // The tap is only valid if it is inside an active target
            if (YES == videoData[i].isActive) {
                touchInTarget = i;
                break;
            }
        }
    }
    
    [dataLock unlock];
    // ----- End synchronise data access -----
    
    return touchInTarget;
}
    
// Get a pointer to a VideoPlayerHelper object held by this EAGLView
- (VideoPlayerHelper*)getVideoPlayerHelper:(int)index
{
    return videoPlayerHelper[index];
}







//------------------------------------------------------------------------------
#pragma mark - UIGLViewProtocol methods

// Draw the current frame using OpenGL
//
// This method is called by QCAR when it wishes to render the current frame to
// the screen.
//
// *** QCAR will call this method periodically on a background thread ***
- (void)renderFrameQCAR
{
    [self setFramebuffer];
    
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Begin QCAR rendering for this frame, retrieving the tracking state
    QCAR::State state = QCAR::Renderer::getInstance().begin();
    
    // Render the video background
    QCAR::Renderer::getInstance().drawVideoBackground();
    
    glEnable(GL_DEPTH_TEST);
    
    // We must detect if background reflection is active and adjust the culling
    // direction.  If the reflection is active, this means the pose matrix has
    // been reflected as well, therefore standard counter clockwise face culling
    // will result in "inside out" models
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    if(QCAR::Renderer::getInstance().getVideoBackgroundConfig().mReflection == QCAR::VIDEO_BACKGROUND_REFLECTION_ON) {
        // Front camera
        glFrontFace(GL_CW);
    }
    else {
        // Back camera
        glFrontFace(GL_CCW);
    }
    
    // Get the active trackables
    int numActiveTrackables = state.getNumTrackableResults();
    
    // ----- Synchronise data access -----
    [dataLock lock];
    
    // Assume all targets are inactive (used when determining tap locations)
    for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        videoData[i].isActive = NO;
    }
    
    // Did we find any trackables this frame?
    for (int i = 0; i < numActiveTrackables; ++i) {
        // Get the trackable
        const QCAR::TrackableResult* trackableResult = state.getTrackableResult(i);
        const QCAR::ImageTarget& imageTarget = (const QCAR::ImageTarget&) trackableResult->getTrackable();
        
        NSString *name = [NSString stringWithCString:imageTarget.getName() encoding:NSUTF8StringEncoding];
        NSLog(@"Image Target Name is %@", name);
        NSString *trimmedName = [name substringToIndex:[name length]-3];
        NSLog(@"Trimmed Target Name is %@", trimmedName);

        
        // VideoPlayerHelper to use for current target
        NSInteger playerIndex = 0;

        if ([trimmedName isEqualToString:@"AMY"]) {
            playerIndex = 0;
        }
        else if ([trimmedName isEqualToString:@"CLAIRE"]) {
            playerIndex = 1;
        }
        else if ([trimmedName isEqualToString:@"JESS"]) {
            playerIndex = 2;
        }
        else if ([trimmedName isEqualToString:@"KIKI"]) {
            playerIndex = 3;
        }
        else if ([trimmedName isEqualToString:@"MARCI"]) {
            playerIndex = 4;
        }
        else if ([trimmedName isEqualToString:@"MILY"]) {
            playerIndex = 5;
        }
        else if ([trimmedName isEqualToString:@"SULTAN1"]) {
            playerIndex = 6;
        }
        else if ([trimmedName isEqualToString:@"SULTAN2"]) {
            playerIndex = 7;
        }
        else {
            playerIndex = -1;
        }
        
        NSLog(@"Player Index is %li", (long)playerIndex);
        
        // Set Filename
        //[self setPathForMovie:playerIndex];
        
        FullScreenVideoControllerViewController *vc = [[FullScreenVideoControllerViewController alloc] initWithNibName:@"FullScreenVideoControllerViewController" bundle:nil];
        vc.currentIndex = &(playerIndex);
        //vc.currentIndex = &(playerIndex);
        //[self.navigationController presentViewController:vc animated:YES completion:nil];
        [videoPlaybackViewController.navigationController presentViewController:vc animated:YES completion:nil];
        
        
        
        
        
        
        
        // Mark this video (target) as active
        videoData[SINGLE_HELPER].isActive = YES;
        
        // Get the target size (used to determine if taps are within the target)
        if (0.0f == videoData[SINGLE_HELPER].targetPositiveDimensions.data[0] ||
            0.0f == videoData[SINGLE_HELPER].targetPositiveDimensions.data[1]) {
            const QCAR::ImageTarget& imageTarget = (const QCAR::ImageTarget&) trackableResult->getTrackable();
            
            //videoData[SINGLE_HELPER].targetPositiveDimensions = imageTarget.getSize();
            QCAR::Vec3F size = imageTarget.getSize();
            videoData[SINGLE_HELPER].targetPositiveDimensions.data[0] = size.data[0];
            videoData[SINGLE_HELPER].targetPositiveDimensions.data[1] = size.data[1];
            
            
            // The pose delivers the centre of the target, thus the dimensions
            // go from -width / 2 to width / 2, and -height / 2 to height / 2
            videoData[SINGLE_HELPER].targetPositiveDimensions.data[0] /= 2.0f;
            videoData[SINGLE_HELPER].targetPositiveDimensions.data[1] /= 2.0f;
        }
        
        // Get the current trackable pose
        const QCAR::Matrix34F& trackablePose = trackableResult->getPose();
        
        // This matrix is used to calculate the location of the screen tap
        videoData[SINGLE_HELPER].modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(trackablePose);
        
        float aspectRatio;
        const GLvoid* texCoords;
        GLuint frameTextureID = 0; // EDIT
        BOOL displayVideoFrame = YES;
        
        // Retain value between calls
        static GLuint videoTextureID[NUM_VIDEO_TARGETS] = {0}; // was NUM_VIDEO_TARGETS
        
        //MEDIA_STATE currentStatus = [videoPlayerHelper[playerIndex] getStatus];
        MEDIA_STATE currentStatus = [singleVideoPlayerHelper getStatus];
        
        NSLog(@"MEDIA_STATE for %d is %d", playerIndex, currentStatus);
        
        // --- INFORMATION ---
        // One could trigger automatic playback of a video at this point.  This
        // could be achieved by calling the play method of the VideoPlayerHelper
        // object if currentStatus is not PLAYING.  You should also call
        // getStatus again after making the call to play, in order to update the
        // value held in currentStatus.
        // --- END INFORMATION ---
        
        switch (currentStatus) {
            case PLAYING: {
                // If the tracking lost timer is scheduled, terminate it
                if (nil != trackingLostTimer) {
                    // Timer termination must occur on the same thread on which it was installed
                    [self performSelectorOnMainThread:@selector(terminateTrackingLostTimer) withObject:nil waitUntilDone:YES];
                }
                
                // Upload the decoded video data for the latest frame to OpenGL and obtain the video texture ID
                //GLuint videoTexID = [videoPlayerHelper[playerIndex] updateVideoData];
                GLuint videoTexID = [singleVideoPlayerHelper updateVideoData];
                
                if (0 == videoTextureID[SINGLE_HELPER]) {
                    videoTextureID[SINGLE_HELPER] = videoTexID;
                }
                
                // Fallthrough
            }
            case PAUSED:
                if (0 == videoTextureID[SINGLE_HELPER]) {
                    // No video texture available, display keyframe
                    displayVideoFrame = NO;
                }
                else {
                    // Display the texture most recently returned from the call
                    // to [videoPlayerHelper updateVideoData]
                    frameTextureID = videoTextureID[playerIndex];
                }
                
                break;
                
            default:
                videoTextureID[SINGLE_HELPER] = 0;
                displayVideoFrame = NO;
                break;
        }
        
        if (YES == displayVideoFrame) {
            // ---- Display the video frame -----
            aspectRatio = (float)[singleVideoPlayerHelper getVideoHeight] / (float)[singleVideoPlayerHelper getVideoWidth];
            texCoords = videoQuadTextureCoords;
        }
        else {
            // ----- Display the keyframe -----
            Texture* t = augmentationTexture[OBJECT_KEYFRAME_1 + playerIndex];
            frameTextureID = [t textureID];
            aspectRatio = (float)[t height] / (float)[t width];
            texCoords = quadTexCoords;
        }
        
        // Get the current projection matrix
        QCAR::Matrix44F projMatrix = vapp.projectionMatrix;
        
        // If the current status is valid (not NOT_READY or ERROR), render the
        // video quad with the texture we've just selected
        if (NOT_READY != currentStatus) {
            // Convert trackable pose to matrix for use with OpenGL
            QCAR::Matrix44F modelViewMatrixVideo = QCAR::Tool::convertPose2GLMatrix(trackablePose);
            QCAR::Matrix44F modelViewProjectionVideo;
            
//            SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, videoData[playerIndex].targetPositiveDimensions.data[0],
//                                             &modelViewMatrixVideo.data[0]);
            
            SampleApplicationUtils::scalePoseMatrix(videoData[SINGLE_HELPER].targetPositiveDimensions.data[0],
                                         videoData[SINGLE_HELPER].targetPositiveDimensions.data[0] * aspectRatio,
                                         videoData[SINGLE_HELPER].targetPositiveDimensions.data[0],
                                         &modelViewMatrixVideo.data[0]);
            
            SampleApplicationUtils::multiplyMatrix(projMatrix.data,
                                        &modelViewMatrixVideo.data[0] ,
                                        &modelViewProjectionVideo.data[0]);
            
            glUseProgram(shaderProgramID);
            
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, quadVertices);
            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, quadNormals);
            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
            
            glEnableVertexAttribArray(vertexHandle);
            glEnableVertexAttribArray(normalHandle);
            glEnableVertexAttribArray(textureCoordHandle);
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, frameTextureID);
            glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (GLfloat*)&modelViewProjectionVideo.data[0]);
            glUniform1i(texSampler2DHandle, 0 /*GL_TEXTURE0*/);
            glDrawElements(GL_TRIANGLES, NUM_QUAD_INDEX, GL_UNSIGNED_SHORT, quadIndices);
            
            glDisableVertexAttribArray(vertexHandle);
            glDisableVertexAttribArray(normalHandle);
            glDisableVertexAttribArray(textureCoordHandle);
            
            glUseProgram(0);
        }
        
        // If the current status is not PLAYING, render an icon
        if (PLAYING != currentStatus) {
            GLuint iconTextureID;
            
            switch (currentStatus) {
                case READY:
                case REACHED_END:
                case PAUSED:
                case STOPPED: {
                    // ----- Display play icon -----
                    iconTextureID = [augmentationTexture[OBJECT_PLAY_ICON] textureID];
                    break;
                }
                    
                case ERROR: {
                    // ----- Display error icon -----
                    iconTextureID = [augmentationTexture[OBJECT_ERROR_ICON] textureID];
                    break;
                }
                    
                default: {
                    // ----- Display busy icon -----
                    iconTextureID = [augmentationTexture[OBJECT_BUSY_ICON] textureID];
                    break;
                }
            }
            
            // Convert trackable pose to matrix for use with OpenGL
            QCAR::Matrix44F modelViewMatrixButton = QCAR::Tool::convertPose2GLMatrix(trackablePose);
            QCAR::Matrix44F modelViewProjectionButton;
            
            //SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON_TRANSLATION, &modelViewMatrixButton.data[0]);
            SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, 5.0f, &modelViewMatrixButton.data[0]);
            
            SampleApplicationUtils::scalePoseMatrix(videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON,
                                         videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON,
                                         videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON,
                                         &modelViewMatrixButton.data[0]);
            
            SampleApplicationUtils::multiplyMatrix(projMatrix.data,
                                        &modelViewMatrixButton.data[0] ,
                                        &modelViewProjectionButton.data[0]);
            
            glDepthFunc(GL_LEQUAL);
            
            glUseProgram(shaderProgramID);
            
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, quadVertices);
            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, quadNormals);
            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, quadTexCoords);
            
            glEnableVertexAttribArray(vertexHandle);
            glEnableVertexAttribArray(normalHandle);
            glEnableVertexAttribArray(textureCoordHandle);
            
            // Blend the icon over the background
            glEnable(GL_BLEND);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, iconTextureID);
            glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (GLfloat*)&modelViewProjectionButton.data[0] );
            glDrawElements(GL_TRIANGLES, NUM_QUAD_INDEX, GL_UNSIGNED_SHORT, quadIndices);
            
            glDisable(GL_BLEND);
            
            glDisableVertexAttribArray(vertexHandle);
            glDisableVertexAttribArray(normalHandle);
            glDisableVertexAttribArray(textureCoordHandle);
            
            glUseProgram(0);
            
            glDepthFunc(GL_LESS);
        }
        
        SampleApplicationUtils::checkGlError("VideoPlayback renderFrameQCAR");
    }
    
    // --- INFORMATION ---
    // One could pause automatic playback of a video at this point.  Simply call
    // the pause method of the VideoPlayerHelper object without setting the
    // timer (as below).
    // --- END INFORMATION ---
    
    // If a video is playing on texture and we have lost tracking, create a
    // timer on the main thread that will pause video playback after
    // TRACKING_LOST_TIMEOUT seconds
    for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        if (nil == trackingLostTimer && NO == videoData[SINGLE_HELPER].isActive && PLAYING == [singleVideoPlayerHelper getStatus]) {
            //[self performSelectorOnMainThread:@selector(createTrackingLostTimer) withObject:nil waitUntilDone:YES];
            break;
        }
    }
    
    [dataLock unlock];
    // ----- End synchronise data access -----
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    QCAR::Renderer::getInstance().end();
    [self presentFramebuffer];

}

// Create the tracking lost timer
- (void)createTrackingLostTimer
{
    trackingLostTimer = [NSTimer scheduledTimerWithTimeInterval:TRACKING_LOST_TIMEOUT target:self selector:@selector(trackingLostTimerFired:) userInfo:nil repeats:NO];
}


// Terminate the tracking lost timer
- (void)terminateTrackingLostTimer
{
    [trackingLostTimer invalidate];
    trackingLostTimer = nil;
}


// Tracking lost timer fired, pause video playback
- (void)trackingLostTimerFired:(NSTimer*)timer
{
    // Tracking has been lost for TRACKING_LOST_TIMEOUT seconds, pause playback
    // (we can safely do this on all our VideoPlayerHelpers objects)
    for (int i = 0; i < NUM_VIDEO_TARGETS; ++i) {
        [videoPlayerHelper[i] pause];
    }
    [singleVideoPlayerHelper pause];
    trackingLostTimer = nil;
}


//------------------------------------------------------------------------------
#pragma mark - OpenGL ES management

- (void)initShaders
{
    shaderProgramID = [SampleApplicationShaderUtils createProgramWithVertexShaderFileName:@"Simple.vertsh"
                                                   fragmentShaderFileName:@"Simple.fragsh"];

    if (0 < shaderProgramID) {
        vertexHandle = glGetAttribLocation(shaderProgramID, "vertexPosition");
        normalHandle = glGetAttribLocation(shaderProgramID, "vertexNormal");
        textureCoordHandle = glGetAttribLocation(shaderProgramID, "vertexTexCoord");
        mvpMatrixHandle = glGetUniformLocation(shaderProgramID, "modelViewProjectionMatrix");
        texSampler2DHandle  = glGetUniformLocation(shaderProgramID,"texSampler2D");
    }
    else {
        NSLog(@"Could not initialise augmentation shader");
    }
}


- (void)createFramebuffer
{
    if (context) {
        // Create default framebuffer object
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create colour renderbuffer and allocate backing store
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        // Allocate the renderbuffer's storage (shared with the drawable object)
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
        GLint framebufferWidth;
        GLint framebufferHeight;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        // Create the depth render buffer and allocate storage
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
        
        // Attach colour and depth render buffers to the frame buffer
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        // Leave the colour render buffer bound so future rendering operations will act on it
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    }
}


- (void)deleteFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer) {
            glDeleteRenderbuffers(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
    }
}


- (void)setFramebuffer
{
    // The EAGLContext must be set for each thread that wishes to use it.  Set
    // it the first time this method is called (on the render thread)
    if (context != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:context];
    }
    
    if (!defaultFramebuffer) {
        // Perform on the main thread to ensure safe memory allocation for the
        // shared buffer.  Block until the operation is complete to prevent
        // simultaneous access to the OpenGL context
        [self performSelectorOnMainThread:@selector(createFramebuffer) withObject:self waitUntilDone:YES];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
}


- (BOOL)presentFramebuffer
{
    // setFramebuffer must have been called before presentFramebuffer, therefore
    // we know the context is valid and has been set for this (render) thread
    
    // Bind the colour render buffer and present it
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    return [context presentRenderbuffer:GL_RENDERBUFFER];
}



@end

