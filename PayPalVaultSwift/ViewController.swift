//
//  ViewController.swift
//  PayPalVaultSwift
//
//  Created by Orcun on 25/10/2016.
//  Copyright © 2016 Orcun. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BTAppSwitchDelegate, BTViewControllerPresentingDelegate  {
    
    var braintreeClient: BTAPIClient?
    
    var price: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let clientTokenURL = NSURL(string: "http://orcodevbox.co.uk/BTOrcun/tokenGen.php")!
        let clientTokenRequest = NSMutableURLRequest(URL: clientTokenURL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        NSURLSession.sharedSession().dataTaskWithRequest(clientTokenRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            let clientToken = String(data: data!, encoding: NSUTF8StringEncoding)
            
            self.braintreeClient = BTAPIClient(authorization: clientToken!)
            
            // Log the client token to confirm that it is returned from server
            NSLog(clientToken!);
            
            // As an example, you may wish to present our Drop-in UI at this point.
            // Continue to the next section to learn more...
            }.resume()
        
        let button = UIButton();
        button.setTitle("Buy", forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        button.frame = CGRectMake(90, 450, 200, 100)
        button.addTarget(self, action: #selector(ViewController.customPayPalButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        
        
    }
    
    func customPayPalButtonTapped(button: UIButton) {
        let payPalDriver = BTPayPalDriver(APIClient: self.braintreeClient!)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self
        
        // Start the Vault flow
        payPalDriver.authorizeAccountWithCompletion() { (tokenizedPayPalAccount, error) -> Void in
            
    
         
            
            let request = BTPayPalRequest()
            request.billingAgreementDescription = "Your agremeent description" //Displayed in customer's PayPal account
           
                if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                    print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                    
                    // Send the nonce to your server-side
                    self.postNonceToServer(tokenizedPayPalAccount.nonce)

                    // Send payment method nonce to your server to create a transaction
                } else if error != nil {
                    // Handle error here...
                } else {
                    // Buyer canceled payment approval
                }
            
            
        }
        

    }
    
    func postNonceToServer(paymentMethodNonce: String) {
        price = 13.00;
        let paymentURL = NSURL(string: "http://orcodevbox.co.uk/BTOrcun/iosPayment.php")!
        let request = NSMutableURLRequest(URL: paymentURL)
        request.HTTPBody = "amount=\(Double(price))&payment_method_nonce=\(paymentMethodNonce)".dataUsingEncoding(NSUTF8StringEncoding);
        request.HTTPMethod = "POST"
        
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            let responseData = String(data: data!, encoding: NSUTF8StringEncoding)
            // Log the response in console
            print(responseData);
            
            // Display the result in an alert view
            dispatch_async(dispatch_get_main_queue(), {
                let alertResponse = UIAlertController(title: "Result", message: "\(responseData)", preferredStyle: UIAlertControllerStyle.Alert)
                
                // add an action to the alert (button)
                alertResponse.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                // show the alert
                self.presentViewController(alertResponse, animated: true, completion: nil)
                
            })
            
            }.resume()
    }


    // MARK: - BTViewControllerPresentingDelegate
    
    func paymentDriver(driver: AnyObject, requestsPresentationOfViewController viewController: UIViewController) {
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    func paymentDriver(driver: AnyObject, requestsDismissalOfViewController viewController: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    

    
    // MARK: - BTAppSwitchDelegate
    
    // Optional - display and hide loading indicator UI
    func appSwitcherWillPerformAppSwitch(appSwitcher: AnyObject) {
        showLoadingUI()
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector: Selector("hideLoadingUI:"), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func appSwitcher(appSwitcher: AnyObject, didPerformSwitchToTarget target: BTAppSwitchTarget) {
        
    }
    
    func appSwitcherWillProcessPaymentInfo(appSwitcher: AnyObject) {
        hideLoadingUI()
    }
    
    // MARK: - Private methods
    
    func showLoadingUI() {
        
    }
    
    func hideLoadingUI() {
        NSNotificationCenter
            .defaultCenter()
            .removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
      
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

