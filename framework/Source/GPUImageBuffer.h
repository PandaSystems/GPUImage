#import "GPUImageFilter.h"

@interface GPUImageBuffer : GPUImageFilter
{
    NSMutableArray *bufferedFramebuffers;
}

@property(readwrite, nonatomic) NSUInteger bufferSize;

- (NSMutableArray*) bufferedFramebuffers;

@end
