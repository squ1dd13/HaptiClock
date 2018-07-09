#import <libactivator/libactivator.h>
#import <AudioToolbox/AudioToolbox.h>

extern "C" void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID, id unknown, NSDictionary *options);

static void hapticFeedbackHard(){
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	NSMutableArray* arr = [NSMutableArray array];
	[arr addObject:[NSNumber numberWithBool:YES]];
	[arr addObject:[NSNumber numberWithInt:30]];
	[dict setObject:arr forKey:@"VibePattern"];
	[dict setObject:[NSNumber numberWithInt:2] forKey:@"Intensity"];
	AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
}

@interface FHActivatorListener : NSObject <LAListener>
@end

@implementation FHActivatorListener

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName
{
	if ([listenerName isEqualToString:@"com.squ1dd13.hapticlock.time"]) {
		event.handled = YES;
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateFormat = @"hhmm"; //no colon because that's stupid given that we are splitting the string

		NSString *timeWanted = [dateFormatter stringFromDate:[NSDate date]];

		NSMutableArray *values = [[NSMutableArray alloc] init]; //if we make an array we can play the haptic more easily
		int firstHour = [[NSString stringWithFormat:@"%c", [timeWanted characterAtIndex:0]] intValue];
		if (firstHour != 0) { [values addObject:@(firstHour)]; } //we don't want to add a vibration at the start

		int secondHour = [[NSString stringWithFormat:@"%c", [timeWanted characterAtIndex:1]] intValue];
		[values addObject:@(secondHour)]; //we have to use @(secondHour) because you can't store an int in an array. We have to use NSNumber

		//characterAtIndex: returns a unichar, so we need the %c to make a string
		int firstMinute = [[NSString stringWithFormat:@"%c", [timeWanted characterAtIndex:2]] intValue];
		[values addObject:@(firstMinute)];

		int secondMinute = [[NSString stringWithFormat:@"%c", [timeWanted characterAtIndex:3]] intValue];
		[values addObject:@(secondMinute)];

		int i;
		for (NSNumber *value in values) {
			if([value intValue] == 0) {
				hapticFeedbackHard();
			} else {
				for(i=0;i<[value intValue];i++) {
					NSLog(@"play");
					AudioServicesPlaySystemSound(1519);
					sleep(1);
				}
			}
			sleep(2);
		}
	} else {
		event.handled = NO;
	}
}

- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName
{
	return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application",  nil];
}

+ (void)load
{
	@autoreleasepool
	{
		FHActivatorListener *listener = [[FHActivatorListener alloc] init];
		[[LAActivator sharedInstance] registerListener:listener forName:@"com.squ1dd13.hapticlock.time"];
	}
}
@end
