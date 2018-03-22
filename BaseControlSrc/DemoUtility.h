// Import Libs
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Macro Vars
#define WeakRef(__obj) __weak typeof(self) __obj = self
#define WeakReturn(__obj) if(__obj ==nil)return;

// Get Classes
@class DJIBaseProduct;
@class DJIAircraft;
@class DJIGimbal;
@class DJIFlightController;
@class DJIRemoteController;

// Define Class
@interface DemoUtility : NSObject
    // Method Defs
    +(DJIBaseProduct*) fetchProduct;
    +(DJIAircraft*) fetchAircraft;
    +(DJIFlightController*) fetchFlightController;
    +(DJIRemoteController*) fetchRemoteController;
    +(void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelAlertAction:(UIAlertAction*)cancelAlert defaultAlertAction:(UIAlertAction*)defaultAlert viewController:(UIViewController *)viewController;
@end
