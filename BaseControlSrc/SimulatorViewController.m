#import "SimulatorViewController.h"
#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>

#define SLEEP_T     8
#define SLEEP_L     10
#define INTERVAL    0.1
#define RADIUS      0.5
#define TIME        5.0
#define LOOPS       1.0
#define ROL_V       ((2.0 * 3.141592 * RADIUS) / TIME)
#define YAW_V       -(360.0 / TIME)
#define RUN         ((TIME / INTERVAL) * LOOPS)

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
            
            // Loop Circle
            for(int i = 0; i <= RUN; i++) {
                // Set Data
                DJIVirtualStickFlightControlData fcData = {0};
                fcData.pitch = (float)ROL_V;
                fcData.roll = (float)0.0;
                fcData.yaw = (float)YAW_V;
                fcData.verticalThrottle = (float)0.0;
                
                // Send Data
                self.Status.text = @"Sending Data";
                printf("Sending Data RUN %d -> Roll: %f,Pitch: %f, Yaw: %f and Throt: %f\n", i, fcData.pitch, fcData.roll, fcData.yaw, fcData.verticalThrottle);
                if (fcint.isVirtualStickControlModeAvailable) {
                    [fcint sendVirtualStickFlightControlData:fcData withCompletion:nil];
                }
                
                // Sleep
                usleep(INTERVAL * 1000000);
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
