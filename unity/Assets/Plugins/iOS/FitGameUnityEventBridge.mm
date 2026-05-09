#import <Foundation/Foundation.h>

extern "C" void FitGameEmitUnityEvent(const char *json)
{
    if (json == NULL) {
        return;
    }

    NSString *event = [NSString stringWithUTF8String:json];
    if (event == nil) {
        return;
    }

    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"FitGameUnityEvent"
        object:event];
}
