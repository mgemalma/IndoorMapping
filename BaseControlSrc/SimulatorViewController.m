#import "SimulatorViewController.h"
#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>

#define SLEEP_T 8   //  8 s
#define SLEEP_L 5  //  15 s
#define SLEEP_S 0.3 //  10 Hz
#define YAW_V   50.0  //  60 deg/s
#define RUN     5000  //  50 Times

@interface SimulatorViewController()<DJIFlightControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *Status;
@end

@implementation SimulatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"DJIRemote";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DJIFlightController* fc = [DemoUtility fetchFlightController];
    if (fc) {
        // Take Off
        self.Status.text = @"TakingOff";
        printf("Taking Off\n");
        [fc startTakeoffWithCompletion:nil];
        
        // Sleep
        sleep(SLEEP_T);
        
        /** Enter Virtual Stick **/
        // Set Control Mode Yaw
        fc.yawControlMode = DJIVirtualStickYawControlModeAngularVelocity;
        
        // Set Control Mode Pitch
        fc.rollPitchControlMode = DJIVirtualStickRollPitchControlModeVelocity;
        
        // Enable Virtual Stick
        self.Status.text = @"Virtual Stick OK";
        printf("Virtual Stick\n");
        [fc setVirtualStickModeEnabled:YES withCompletion:^(NSError * _Nullable error) {
            /** Send Stick Input **/
            // Get Flight Controller
            DJIFlightController* fcint = [DemoUtility fetchFlightController];
            
            // Loop
            for(int i = 0; i <= RUN; i++) {
                // Set Data
                DJIVirtualStickFlightControlData fcData = {0};
                fcData.pitch = (float)0.0;
                fcData.roll = (float)0.0;
                fcData.yaw = (float)50.0;
                fcData.verticalThrottle = (float)0.0;
                
                // Send Data
                self.Status.text = @"Sending Data";
                printf("Sending Data %d\n", i);
                if (fcint.isVirtualStickControlModeAvailable) {
                    [fcint sendVirtualStickFlightControlData:fcData withCompletion:nil];
                }
                
                // Lock
                
                // Sleep
                sleep(SLEEP_S);
            }
            
            // Sleep
            sleep(SLEEP_L);
            
            // Land
            self.Status.text = @"Landing";
            printf("Landing\n");
            [fcint startLandingWithCompletion:nil];
        }];
    }
}
@end
