// Import Libs
#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>
// Class Implementation
@implementation DemoUtility
    /** Method Implementation **/

    // Returns DJI Product Instance
    +(DJIBaseProduct*) fetchProduct {
        return [DJISDKManager product];
    }

    // Returns DJI Aircraft Instance
    +(DJIAircraft*) fetchAircraft {
        // Nil if No DJI Product
        if (![DJISDKManager product]) {
            return nil;
        }
        
        // Return Aircraft Instance
        if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
            return ((DJIAircraft*)[DJISDKManager product]);
        }
        
        // Nil if Not of Aircraft Type
        return nil;
    }

    // Return DJI Flight Controller Instance
    +(DJIFlightController*) fetchFlightController {
        // Nil if No DJI Product
        if (![DJISDKManager product]) {
            return nil;
        }
        
        // Return Flight Controller Instance
        if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
            return ((DJIAircraft*)[DJISDKManager product]).flightController;
        }
        
        // Nil if Not of Aircraft Type
        return nil;
    }

    // Used to Give Alert - Depricate
    +(void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelAlertAction:(UIAlertAction*)cancelAlert defaultAlertAction:(UIAlertAction*)defaultAlert viewController:(UIViewController *)viewController {
        // Create Alert
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        // Cancel Alert Action
        if (cancelAlert) {
            [alertController addAction:cancelAlert];
        }
        
        // Set Alert
        if (defaultAlert) {
            [alertController addAction: defaultAlert];
        }
        
        // Present Alert
        [viewController presentViewController:alertController animated:YES completion:nil];
    }
@end

