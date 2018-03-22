#import "SimulatorViewController.h"
#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>

#define SLEEP 10

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
        [fc startTakeoffWithCompletion:^(NSError * _Nullable error) {}];
        
        // Sleep
        sleep(SLEEP);
        
        // Land
        self.Status.text = @"Landing";
        [fc startLandingWithCompletion:^(NSError * _Nullable error) {}];
    }
}
@end
