#import "RootViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"

@interface RootViewController ()<DJISDKManagerDelegate>


//The IBOutlets for the UI connection
@property(nonatomic, weak) DJIBaseProduct* product;
@property (weak, nonatomic) IBOutlet UILabel *connectStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@end

//Class Decleration For The RootViewController
@implementation RootViewController
    /** Main Methods **/

    //Check if the view loaded
    - (void)viewDidLoad {
        [super viewDidLoad];
        [self initUI];
    }

    //Check if the view appeared
    - (void)viewDidAppear:(BOOL)animated {
        [super viewDidAppear:animated];
        
        //Please enter the App Key in info.plist file to register the app.
        [DJISDKManager registerAppWithDelegate:self];
        
        //If the product exists then update the status
        if(self.product) {
            [self updateStatusBasedOn:self.product];
        }
    }

    //Initialize the UI
    - (void)initUI {
        self.title = @"DJISimulator Demo";
        self.modelNameLabel.hidden = YES;
        //Disable the connect button by default
        [self.connectButton setEnabled:NO];
    }

    /** DJI Methods **/

    //Check the status of the Product
    -(void) updateStatusBasedOn:(DJIBaseProduct* )newConnectedProduct {
        
        //If the DJI SDK product is connected then in a UI notification show it
        if (newConnectedProduct){
            //Print the connected Model type on the UI
            self.connectStatusLabel.text = NSLocalizedString(@"Status: Product Connected", @"");
            self.modelNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Model: \%@", @""),newConnectedProduct.model];
            self.modelNameLabel.hidden = NO;
            
        }
        //Else print that the product is not connected and consequently model is unknown
        else {
            self.connectStatusLabel.text = NSLocalizedString(@"Status: Product Not Connected", @"");
            self.modelNameLabel.text = NSLocalizedString(@"Model: Unknown", @"");
        }
    }

    //Check the connection of the product
    - (void)productConnected:(DJIBaseProduct *)product {
        
        //If the Product is connected
        if (product) {
            //Initialize the product type
            self.product = product;
            
            //Since the product type is clear then set the connection button enabled
            [self.connectButton setEnabled:YES];
            
        }
        //If the product is not connected
        else {
            
            
            //Print the message that the connection is lost
            NSString* message = [NSString stringWithFormat:@"Connection lost. Back to root."];
            
            //Aler the UI that the connection can't be established
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *backAction = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                if (![self.navigationController.topViewController isKindOfClass:[RootViewController class]]) {
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }
            }];
            
            //Update the variables accordingly since there is no connection established
            [DemoUtility showAlertViewWithTitle:nil message:message cancelAlertAction:cancelAction defaultAlertAction:backAction viewController:self];
            
            [self.connectButton setEnabled:NO];
            self.product = nil;
        }
        
        //According to the product information update the product variable
        [self updateStatusBasedOn:product];
        
        //If this demo is used in China, it's required to login to your DJI account to activate the application. Also you need to use DJI Go app to bind the aircraft to your DJI account. For more details, please check this demo's tutorial.
        [[DJISDKManager userAccountManager] logIntoDJIUserAccountWithAuthorizationRequired:NO withCompletion:^(DJIUserAccountState state, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Login failed: %@", error.description);
            }
        }];
    }

    //Check if there is memory warning
    - (void)didReceiveMemoryWarning {
        [super didReceiveMemoryWarning];
    }

    #pragma mark - DJISDKManager Delegate Methods


    //Check if the app registered with error
    - (void)appRegisteredWithError:(NSError *)error
    {
        
        //If there is no error start connection to the product
        if (!error) {
            
            [DJISDKManager startConnectionToProduct];
            
        }
        
        //If the connection can't be established then show it on UI
        else
        {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [DemoUtility showAlertViewWithTitle:nil message:[NSString stringWithFormat:@"Registration Error:%@", error] cancelAlertAction:cancelAction defaultAlertAction:nil viewController:self];
            
            [self.connectButton setEnabled:NO];
        }
        
    }
@end
