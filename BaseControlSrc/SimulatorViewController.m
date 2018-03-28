#import "SimulatorViewController.h"
#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>

#define SLEEP_T 8           //  8 s
#define SLEEP_L 10           //  15 s
#define SLEEP_S 0.1        //  10 Hz
#define YAW_V   -18.0      //  60 deg/s
#define ROL_V   0.25        //  1 m/s
#define RUN     40      //  5000 Times

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
        
        // Disable Obstical Avoidance
        [fc.flightAssistant setCollisionAvoidanceEnabled:NO withCompletion:nil];
        printf("Turning off Obstacle Avoidance \n");
        
        // Sleep
        sleep(SLEEP_T);
        
        /** Enter Virtual Stick **/
        // Set Control Mode Yaw
        fc.yawControlMode = DJIVirtualStickYawControlModeAngularVelocity;
        
        // Set Control Mode Pitch
        fc.rollPitchControlMode = DJIVirtualStickRollPitchControlModeVelocity;
        fc.rollPitchCoordinateSystem = DJIVirtualStickFlightCoordinateSystemBody;
        
        // Enable Virtual Stick
        self.Status.text = @"Virtual Stick OK";
        printf("Virtual Stick\n");
        
        [fc setVirtualStickModeEnabled:YES withCompletion:^(NSError * _Nullable error) {
            /** Send Stick Input **/
            // Get Flight Controller
            DJIFlightController* fcint = [DemoUtility fetchFlightController];
            
            for(int j = 0; j < 4; j++) {
            
            // Loop Right
            for(int i = 0; i <= RUN; i++) {
                // Set Data
                DJIVirtualStickFlightControlData fcData = {0};
                fcData.pitch = (float)ROL_V;
                fcData.roll = (float)0.0;
                fcData.yaw = (float)0.0;
                fcData.verticalThrottle = (float)0.0;
                
                // Send Data
                self.Status.text = @"Sending Data";
                printf("Sending Data %d\n", i);
                if (fcint.isVirtualStickControlModeAvailable) {
                    [fcint sendVirtualStickFlightControlData:fcData withCompletion:nil];
                }
                
                // Sleep
                usleep(SLEEP_S * 1000000);
            }
            
            // Loop Rotate
            for(int i = 0; i <= RUN; i++) {
                // Set Data
                DJIVirtualStickFlightControlData fcData = {0};
                fcData.pitch = (float)0.0;
                fcData.roll = (float) 0.0;
                fcData.yaw = (float) YAW_V;
                fcData.verticalThrottle = (float)0.0;
                
                // Send Data
                self.Status.text = @"Sending Data";
                printf("Sending Data %d\n", i);
                if (fcint.isVirtualStickControlModeAvailable) {
                    [fcint sendVirtualStickFlightControlData:fcData withCompletion:nil];
                }
                
                // Sleep
                usleep(SLEEP_S * 1000000);
            }
            }
            
            // Emable Controller
            printf("Enable Controller \n");
            [fcint setVirtualStickModeEnabled:NO withCompletion:nil];
            
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
