#import "GPUImageLaplacianFilter.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageLaplacianFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 uniform sampler2D inputImageTexture;
 
 uniform mediump mat3 convolutionMatrix;
 
 varying vec2 textureCoordinate;
 varying vec2 leftTextureCoordinate;
 varying vec2 rightTextureCoordinate;
 
 varying vec2 topTextureCoordinate;
 varying vec2 topLeftTextureCoordinate;
 varying vec2 topRightTextureCoordinate;
 
 varying vec2 bottomTextureCoordinate;
 varying vec2 bottomLeftTextureCoordinate;
 varying vec2 bottomRightTextureCoordinate;
 
 void main()
 {
     lowp vec3 bottomColor = texture2D(inputImageTexture, bottomTextureCoordinate).rgb;
     lowp vec3 bottomLeftColor = texture2D(inputImageTexture, bottomLeftTextureCoordinate).rgb;
     lowp vec3 bottomRightColor = texture2D(inputImageTexture, bottomRightTextureCoordinate).rgb;
     lowp vec4 centerColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec3 leftColor = texture2D(inputImageTexture, leftTextureCoordinate).rgb;
     lowp vec3 rightColor = texture2D(inputImageTexture, rightTextureCoordinate).rgb;
     lowp vec3 topColor = texture2D(inputImageTexture, topTextureCoordinate).rgb;
     lowp vec3 topRightColor = texture2D(inputImageTexture, topRightTextureCoordinate).rgb;
     lowp vec3 topLeftColor = texture2D(inputImageTexture, topLeftTextureCoordinate).rgb;
     
     lowp float number = 0.0;
     
     number += bottomColor.r;
     number += bottomColor.g;
     number += bottomColor.b;
     
     number += bottomLeftColor.r;
     number += bottomLeftColor.g;
     number += bottomLeftColor.b;
     
     number += leftColor.r;
     number += leftColor.g;
     number += leftColor.b;
     
     number += rightColor.r;
     number += rightColor.g;
     number += rightColor.b;
     
     number += topColor.r;
     number += topColor.g;
     number += topColor.b;
     
     number += bottomRightColor.r;
     number += bottomRightColor.g;
     number += bottomRightColor.b;
     
     number += topRightColor.r;
     number += topRightColor.g;
     number += topRightColor.b;
     
     number += topLeftColor.r;
     number += topLeftColor.g;
     number += topLeftColor.b;
     
     number /= 3.0;
     
     lowp float current = (centerColor.r + centerColor.g + centerColor.b) / 3.0;
     
     lowp vec4 newColor = vec4(0.0, 0.0, 0.0, 1.0);
     
     if (current > 0.5) {
         if (number < 1.5) {
             newColor = vec4(0.0, 0.0, 0.0, 1.0);
         }
         if (number > 3.5) {
             newColor = vec4(0.0, 0.0, 0.0, 1.0);
         }
         
         if (number < 3.5 && number > 1.5) {
             newColor = vec4(1.0, 1.0, 1.0, 1.0);
         }
     }
     
     if (current < 0.5) {
         if (number < 3.5 && number > 2.5) {
             newColor = vec4(1.0, 1.0, 1.0, 1.0);
         } else {
             newColor = vec4(0.0, 0.0, 0.0, 1.0);
         }
     }
     
     gl_FragColor = newColor;
 }
);
#else
NSString *const kGPUImageLaplacianFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 uniform mat3 convolutionMatrix;
 
 varying vec2 textureCoordinate;
 varying vec2 leftTextureCoordinate;
 varying vec2 rightTextureCoordinate;
 
 varying vec2 topTextureCoordinate;
 varying vec2 topLeftTextureCoordinate;
 varying vec2 topRightTextureCoordinate;
 
 varying vec2 bottomTextureCoordinate;
 varying vec2 bottomLeftTextureCoordinate;
 varying vec2 bottomRightTextureCoordinate;
 
 void main()
 {
     vec3 bottomColor = texture2D(inputImageTexture, bottomTextureCoordinate).rgb;
     vec3 bottomLeftColor = texture2D(inputImageTexture, bottomLeftTextureCoordinate).rgb;
     vec3 bottomRightColor = texture2D(inputImageTexture, bottomRightTextureCoordinate).rgb;
     vec4 centerColor = texture2D(inputImageTexture, textureCoordinate);
     vec3 leftColor = texture2D(inputImageTexture, leftTextureCoordinate).rgb;
     vec3 rightColor = texture2D(inputImageTexture, rightTextureCoordinate).rgb;
     vec3 topColor = texture2D(inputImageTexture, topTextureCoordinate).rgb;
     vec3 topRightColor = texture2D(inputImageTexture, topRightTextureCoordinate).rgb;
     vec3 topLeftColor = texture2D(inputImageTexture, topLeftTextureCoordinate).rgb;
     
     vec3 resultColor = topLeftColor * convolutionMatrix[0][0] + topColor * convolutionMatrix[0][1] + topRightColor * convolutionMatrix[0][2];
     resultColor += leftColor * convolutionMatrix[1][0] + centerColor.rgb * convolutionMatrix[1][1] + rightColor * convolutionMatrix[1][2];
     resultColor += bottomLeftColor * convolutionMatrix[2][0] + bottomColor * convolutionMatrix[2][1] + bottomRightColor * convolutionMatrix[2][2];
     
     // Normalize the results to allow for negative gradients in the 0.0-1.0 colorspace
     resultColor = resultColor + 0.5;

     gl_FragColor = vec4(resultColor, centerColor.a);
 }
);
#endif

@implementation GPUImageLaplacianFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageLaplacianFragmentShaderString]))
    {
		return nil;
    }
    
    GPUMatrix3x3 newConvolutionMatrix;
    newConvolutionMatrix.one.one = 0.5;
    newConvolutionMatrix.one.two = 1.0;
    newConvolutionMatrix.one.three = 0.5;
    
    newConvolutionMatrix.two.one = 1.0;
    newConvolutionMatrix.two.two = -6.0;
    newConvolutionMatrix.two.three = 1.0;
    
    newConvolutionMatrix.three.one = 0.5;
    newConvolutionMatrix.three.two = 1.0;
    newConvolutionMatrix.three.three = 0.5;
    
    self.convolutionKernel = newConvolutionMatrix;
    
    return self;
}

@end
