/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/

#import <UIKit/UIKit.h>

#import <QCAR/UIGLViewProtocol.h>

#import "Texture.h"
#import "SampleApplicationSession.h"
#import "VideoPlayerHelper.h"


// was 5 + 2
#define NUM_VIDEO_TARGETS 9
#define NUM_AUGMENTATION_TEXTURES NUM_VIDEO_TARGETS + 3
#define SINGLE_HELPER 0

// VideoPlayback is a subclass of UIView and conforms to the informal protocol
// UIGLViewProtocol
@interface VideoPlaybackEAGLView : UIView <UIGLViewProtocol> {
@private
    // Instantiate one VideoPlayerHelper per target
    VideoPlayerHelper *videoPlayerHelper[NUM_VIDEO_TARGETS];
    VideoPlayerHelper *singleVideoPlayerHelper;
    float videoPlaybackTime[NUM_VIDEO_TARGETS];
    
    // Paths
    NSArray  *remoteFiles;
    NSArray  *localFiles;
    NSString *LOCAL_MEDIA_PATH;
    NSString *REMOTE_MEDIA_PATH;
    NSString *LOCAL_FILE;
    
    VideoPlaybackViewController * videoPlaybackViewController ;
    
    // Timer to pause on-texture video playback after tracking has been lost.
    // Note: written/read on two threads, but never concurrently
    NSTimer* trackingLostTimer;
    
    // Coordinates of user touch
    float touchLocation_X;
    float touchLocation_Y;
    
    // indicates how the video will be played
    BOOL playVideoFullScreen;
    
    // Lock to synchronise data that is (potentially) accessed concurrently
    NSLock* dataLock;
    
    
    // OpenGL ES context
    EAGLContext *context;
    
    // The OpenGL ES names for the framebuffer and renderbuffers used to render
    // to this view
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;

    // Shader handles
    GLuint shaderProgramID;
    GLint vertexHandle;
    GLint normalHandle;
    GLint textureCoordHandle;
    GLint mvpMatrixHandle;
    GLint texSampler2DHandle;
    
    // Texture used when rendering augmentation
    Texture* augmentationTexture[NUM_AUGMENTATION_TEXTURES];

    SampleApplicationSession * vapp;
}

- (id)initWithFrame:(CGRect)frame rootViewController:(VideoPlaybackViewController *) rootViewController appSession:(SampleApplicationSession *) app;

- (void) willPlayVideoFullScreen:(BOOL) fullScreen;

- (void) setPaths;
- (void) prepareSinglePlayer;
- (void) prepare;
- (void) dismiss;

- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;

- (bool) handleTouchPoint:(CGPoint) touchPoint;

- (void) preparePlayers;
- (void) dismissPlayers;

@end

