//
//  ViewController.m
//  KEContactPicker
//
//  Created by Kaan Esin on 24.01.2018.
//  Copyright © 2018 Kaan Esin. All rights reserved.
//

#import "ViewController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

@interface ViewController () <CNContactPickerDelegate,CNContactViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *txtView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)contactViewController:(CNContactViewController *)viewController shouldPerformDefaultActionForContactProperty:(CNContactProperty *)property{
    if (property && property.contact.givenName && property.contact.phoneNumbers.count > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"%@ -> %@ clicked",property.contact.givenName,((CNPhoneNumber*)property.contact.phoneNumbers[0].value).stringValue] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:TRUE completion:nil];
    }
    return NO;
}
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact{
    self.txtView.text = @"";
    
    CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
    NSString *contactStr = [formatter stringFromContact:contact];
    NSLog(@"contactStr:%@",contactStr);
    [self updateTextView:contactStr];
    NSArray<CNLabeledValue<NSString*>*> *emailAddresses = contact.emailAddresses;
    NSLog(@"emailAddresses:%@",emailAddresses);
    NSString *emailAddress = emailAddresses.firstObject.value;
    NSLog(@"emailAddress:%@",emailAddress);
    [self updateTextView:emailAddress];
    
    if (contact.imageDataAvailable) {
        NSData *imgData = contact.imageData;
        if (imgData) {
            UIImage *img = [UIImage imageWithData:imgData];
            NSLog(@"img size width/height:%f",img.size.width/img.size.height);
            [self updateTextView:[NSString stringWithFormat:@"img size width/height:%f",img.size.width/img.size.height]];
        }
    }
    
    NSArray<CNLabeledValue<CNPhoneNumber*>*> *phoneNumbers = contact.phoneNumbers;
    NSLog(@"phoneNumbers:%@",phoneNumbers);
    if (phoneNumbers.count > 0) {
        for (int i=0; i<phoneNumbers.count; i++) {
            [self updateTextView:((CNPhoneNumber*)phoneNumbers[i].value).stringValue];
        }
    }
    
    NSArray<CNLabeledValue<CNPostalAddress*>*> *postalAddresses = contact.postalAddresses;
    NSLog(@"postalAddresses:%@",postalAddresses);
    if (postalAddresses.count > 0) {
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).street];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).subLocality];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).city];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).subAdministrativeArea];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).state];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).postalCode];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).country];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).ISOCountryCode];
    }
    
    NSArray<CNLabeledValue<NSString*>*> *urlAddresses = contact.urlAddresses;
    NSLog(@"urlAddresses:%@",urlAddresses);
    if (urlAddresses.count > 0) {
        [self updateTextView:((NSString*)urlAddresses[0].value)];
    }
    
    NSArray<CNLabeledValue<CNContactRelation*>*> *contactRelations = contact.contactRelations;
    NSLog(@"contactRelations:%@",contactRelations);
    if (contactRelations.count > 0) {
        [self updateTextView:((CNContactRelation*)contactRelations[0].value).name];
    }
    
    NSArray<CNLabeledValue<CNSocialProfile*>*> *socialProfiles = contact.socialProfiles;
    NSLog(@"socialProfiles:%@",socialProfiles);
    if (socialProfiles.count > 0) {
        [self updateTextView:((CNSocialProfile*)socialProfiles[0].value).urlString];
        [self updateTextView:((CNSocialProfile*)socialProfiles[0].value).username];
        [self updateTextView:((CNSocialProfile*)socialProfiles[0].value).userIdentifier];
        [self updateTextView:((CNSocialProfile*)socialProfiles[0].value).service];
    }
    
    NSArray<CNLabeledValue<CNInstantMessageAddress*>*> *instantMessageAddresses = contact.instantMessageAddresses;
    NSLog(@"instantMessageAddresses:%@",instantMessageAddresses);
    if (instantMessageAddresses.count > 0) {
        [self updateTextView:((CNInstantMessageAddress*)instantMessageAddresses[0].value).username];
        [self updateTextView:((CNInstantMessageAddress*)instantMessageAddresses[0].value).service];
    }
}
- (IBAction)showCreateContact:(id)sender {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"This app previously was refused permissions to contacts; Please go to settings and grant permission to this app so it can add the desired contact" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:TRUE completion:nil];
        return;
    }
    
    CNContactStore *store = [[CNContactStore alloc] init];
    
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // user didn't grant access;
                // so, again, tell user here why app needs permissions in order  to do it's job;
                // this is dispatched to the main queue because this request could be running on background thread
            });
            return;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            CNContactStore *store = [[CNContactStore alloc] init];
            
            // create contact
            
            CNMutableContact *contact = [[CNMutableContact alloc] init];
            contact.familyName = @"Smith";
            contact.givenName = @"Jane";
            
            CNLabeledValue *homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[CNPhoneNumber phoneNumberWithStringValue:@"301-555-1212"]];
            contact.phoneNumbers = @[homePhone];
            
            CNContactViewController *controller = [CNContactViewController viewControllerForUnknownContact:contact];
            controller.contactStore = store;
            controller.delegate = self;
            
            [self.navigationController pushViewController:controller animated:TRUE];
        });
    }];
}
- (IBAction)addContact:(id)sender {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"This app previously was refused permissions to contacts; Please go to settings and grant permission to this app so it can add the desired contact" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:TRUE completion:nil];
        return;
    }

    CNContactStore *store = [[CNContactStore alloc] init];

    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // user didn't grant access;
                // so, again, tell user here why app needs permissions in order  to do it's job;
                // this is dispatched to the main queue because this request could be running on background thread
            });
            return;
        }

        // create contact

        CNMutableContact *contact = [[CNMutableContact alloc] init];
        contact.familyName = @"Doe";
        contact.givenName = @"John";

        CNLabeledValue *homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[CNPhoneNumber phoneNumberWithStringValue:@"312-555-1212"]];
        CNLabeledValue *workPhone = [CNLabeledValue labeledValueWithLabel:CNLabelWork value:[CNPhoneNumber phoneNumberWithStringValue:@"2223331122"]];
        CNLabeledValue *otherPhone = [CNLabeledValue labeledValueWithLabel:CNLabelOther value:[CNPhoneNumber phoneNumberWithStringValue:@"+905068736655"]];
        CNLabeledValue *otherPhone2 = [CNLabeledValue labeledValueWithLabel:CNLabelOther value:[CNPhoneNumber phoneNumberWithStringValue:@"90506 321 22 33"]];

        contact.phoneNumbers = @[homePhone,workPhone,otherPhone,otherPhone2];

        CNSaveRequest *request = [[CNSaveRequest alloc] init];
        [request addContact:contact toContainerWithIdentifier:nil];

        // save it

        NSError *saveError;
        if (![store executeSaveRequest:request error:&saveError]) {
            NSLog(@"error = %@", saveError);
        }
    }];
}
- (IBAction)selectContactFromPicker:(id)sender {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"This app previously was refused permissions to contacts; Please go to settings and grant permission to this app so it can add the desired contact" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:TRUE completion:nil];
        return;
    }
    
    CNContactStore *store = [[CNContactStore alloc] init];
    
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // user didn't grant access;
                // so, again, tell user here why app needs permissions in order  to do it's job;
                // this is dispatched to the main queue because this request could be running on background thread
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"This app previously was refused permissions to contacts; Please go to settings and grant permission to this app so it can add the desired contact" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:TRUE completion:nil];
            });
            return;
        }
        
        CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
        //        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"emailAddresses.@count > 0"];
        //        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(key == 'fullname') AND (value LIKE 'Kaan')"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"phoneNumbers.@count > 2"];
        picker.predicateForEnablingContact = predicate;
        picker.predicateForSelectionOfContact = predicate;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }];
}
-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    self.txtView.text = @"";
    
    CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
    NSString *contactStr = [formatter stringFromContact:contact];
    NSLog(@"contactStr:%@",contactStr);
    [self updateTextView:contactStr];
    NSArray<CNLabeledValue<NSString*>*> *emailAddresses = contact.emailAddresses;
    NSLog(@"emailAddresses:%@",emailAddresses);
    NSString *emailAddress = emailAddresses.firstObject.value;
    NSLog(@"emailAddress:%@",emailAddress);
    [self updateTextView:emailAddress];
    
    if (contact.imageDataAvailable) {
        NSData *imgData = contact.imageData;
        if (imgData) {
            UIImage *img = [UIImage imageWithData:imgData];
            NSLog(@"img size width/height:%f",img.size.width/img.size.height);
            [self updateTextView:[NSString stringWithFormat:@"img size width/height:%f",img.size.width/img.size.height]];
        }
    }
    
    NSArray<CNLabeledValue<CNPhoneNumber*>*> *phoneNumbers = contact.phoneNumbers;
    NSLog(@"phoneNumbers:%@",phoneNumbers);
    if (phoneNumbers.count > 0) {
        for (int i=0; i<phoneNumbers.count; i++) {
            [self updateTextView:((CNPhoneNumber*)phoneNumbers[i].value).stringValue];
        }
    }
    
    NSArray<CNLabeledValue<CNPostalAddress*>*> *postalAddresses = contact.postalAddresses;
    NSLog(@"postalAddresses:%@",postalAddresses);
    if (postalAddresses.count > 0) {
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).street];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).subLocality];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).city];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).subAdministrativeArea];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).state];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).postalCode];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).country];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).ISOCountryCode];
    }
    
    NSArray<CNLabeledValue<NSString*>*> *urlAddresses = contact.urlAddresses;
    NSLog(@"urlAddresses:%@",urlAddresses);
    if (urlAddresses.count > 0) {
        [self updateTextView:((NSString*)urlAddresses[0].value)];
    }
    
    NSArray<CNLabeledValue<CNContactRelation*>*> *contactRelations = contact.contactRelations;
    NSLog(@"contactRelations:%@",contactRelations);
    if (contactRelations.count > 0) {
        [self updateTextView:((CNContactRelation*)contactRelations[0].value).name];
    }
    
    NSArray<CNLabeledValue<CNSocialProfile*>*> *socialProfiles = contact.socialProfiles;
    NSLog(@"socialProfiles:%@",socialProfiles);
    if (socialProfiles.count > 0) {
        [self updateTextView:((CNSocialProfile*)socialProfiles[0].value).urlString];
        [self updateTextView:((CNSocialProfile*)socialProfiles[0].value).username];
        [self updateTextView:((CNSocialProfile*)socialProfiles[0].value).userIdentifier];
        [self updateTextView:((CNSocialProfile*)socialProfiles[0].value).service];
    }
    
    NSArray<CNLabeledValue<CNInstantMessageAddress*>*> *instantMessageAddresses = contact.instantMessageAddresses;
    NSLog(@"instantMessageAddresses:%@",instantMessageAddresses);
    if (instantMessageAddresses.count > 0) {
        [self updateTextView:((CNInstantMessageAddress*)instantMessageAddresses[0].value).username];
        [self updateTextView:((CNInstantMessageAddress*)instantMessageAddresses[0].value).service];
    }
}
- (IBAction)getContactInformation:(id)sender {
    CNContactStore *contactStore = [[CNContactStore alloc] init];

    switch ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]) {
        case CNAuthorizationStatusAuthorized:
        {
            NSLog(@"contact store is authorized");
            
            [self retrieveContactsWithStore:contactStore];
        }
            break;
        case CNAuthorizationStatusDenied:
        {
            NSLog(@"contact store is denied");
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"This app previously was refused permissions to contacts; Please go to settings and grant permission to this app so it can add the desired contact" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:TRUE completion:nil];
            return;
        }
            break;
        case CNAuthorizationStatusRestricted:
        {
            NSLog(@"contact store is restricted");
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"This app previously was refused permissions to contacts; Please go to settings and grant permission to this app so it can add the desired contact" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:TRUE completion:nil];
            return;
        }
            break;
        case CNAuthorizationStatusNotDetermined:
        {
            NSLog(@"contact store is not determined");
            
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (!granted || error) {
                    NSLog(@"contact store request is not granted or there is an error");
                }
                else {
                    NSLog(@"contact store is granted");
                    
                    [self retrieveContactsWithStore:contactStore];
                }
            }];
        }
            break;
        default:
            break;
    }
    
}

-(void)retrieveContactsWithStore:(CNContactStore*)contactStore{
    self.txtView.text = @"";

    NSError *err;
    NSArray<CNGroup*> *groups = [contactStore groupsMatchingPredicate:nil error:&err];
    NSPredicate *predicate = [CNContact predicateForContactsInGroupWithIdentifier:groups[0].identifier];

    NSArray<CNContact*> *contacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:@[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactGivenNameKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactImageDataKey,CNContactImageDataAvailableKey,CNContactPhoneNumbersKey,CNContactUrlAddressesKey,CNContactRelationsKey,CNContactSocialProfilesKey,CNContactInstantMessageAddressesKey] error:&err];
    NSLog(@"contacts:%@",contacts);
    
    CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
    CNContact *contact = contacts[0];
    NSString *contactStr = [formatter stringFromContact:contact];
    NSLog(@"contactStr:%@",contactStr);
    [self updateTextView:contactStr];
    NSArray<CNLabeledValue<NSString*>*> *emailAddresses = contact.emailAddresses;
    NSLog(@"emailAddresses:%@",emailAddresses);
    NSString *emailAddress = emailAddresses.firstObject.value;
    NSLog(@"emailAddress:%@",emailAddress);
    [self updateTextView:emailAddress];
    
    if (contact.imageDataAvailable) {
        NSData *imgData = contact.imageData;
        if (imgData) {
            UIImage *img = [UIImage imageWithData:imgData];
            NSLog(@"img size width/height:%f",img.size.width/img.size.height);
            [self updateTextView:[NSString stringWithFormat:@"img size width/height:%f",img.size.width/img.size.height]];
        }
    }
    
    NSArray<CNLabeledValue<CNPhoneNumber*>*> *phoneNumbers = contact.phoneNumbers;
    NSLog(@"phoneNumbers:%@",phoneNumbers);
    if (phoneNumbers.count > 0) {
        [self updateTextView:((CNPhoneNumber*)phoneNumbers[0].value).stringValue];
    }

    NSArray<CNLabeledValue<CNPostalAddress*>*> *postalAddresses = contact.postalAddresses;
    NSLog(@"postalAddresses:%@",postalAddresses);
    if (postalAddresses.count > 0) {
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).street];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).subLocality];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).city];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).subAdministrativeArea];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).state];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).postalCode];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).country];
        [self updateTextView:((CNPostalAddress*)postalAddresses[0].value).ISOCountryCode];
    }

    NSArray<CNLabeledValue<NSString*>*> *urlAddresses = contact.urlAddresses;
    NSLog(@"urlAddresses:%@",urlAddresses);
    if (urlAddresses.count > 0) {
        [self updateTextView:((NSString*)urlAddresses[0].value)];
    }

    NSArray<CNLabeledValue<CNContactRelation*>*> *contactRelations = contact.contactRelations;
    NSLog(@"contactRelations:%@",contactRelations);
    if (contactRelations.count > 0) {
        [self updateTextView:((CNContactRelation*)contactRelations[0].value).name];
    }

    NSArray<CNLabeledValue<CNSocialProfile*>*> *socialProfiles = contact.socialProfiles;
    NSLog(@"socialProfiles:%@",socialProfiles);
    if (socialProfiles.count > 0) {
        [self updateTextView:((CNSocialProfile*)socialProfiles[0].value).urlString];
        [self updateTextView:((CNSocialProfile*)socialProfiles[0].value).username];
        [self updateTextView:((CNSocialProfile*)socialProfiles[0].value).userIdentifier];
        [self updateTextView:((CNSocialProfile*)socialProfiles[0].value).service];
    }

    NSArray<CNLabeledValue<CNInstantMessageAddress*>*> *instantMessageAddresses = contact.instantMessageAddresses;
    NSLog(@"instantMessageAddresses:%@",instantMessageAddresses);
    if (instantMessageAddresses.count > 0) {
        [self updateTextView:((CNInstantMessageAddress*)instantMessageAddresses[0].value).username];
        [self updateTextView:((CNInstantMessageAddress*)instantMessageAddresses[0].value).service];
    }

    predicate = [CNContact predicateForContactsMatchingName:@"Esin"];
    contacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:@[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactGivenNameKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactImageDataKey,CNContactImageDataAvailableKey,CNContactPhoneNumbersKey,CNContactUrlAddressesKey,CNContactRelationsKey,CNContactSocialProfilesKey,CNContactInstantMessageAddressesKey] error:&err];
    NSLog(@"predicated contacts with 'Kaan':%@",contacts);
    
    if (contacts.count > 0) {
        contact = contacts[0];
        contactStr = [formatter stringFromContact:contact];
        NSLog(@"contactStr:%@",contactStr);
        [self updateTextView:contactStr];
    }
}
-(void)updateTextView:(NSString*)text{
    self.txtView.text = [NSString stringWithFormat:@"%@\n%@",self.txtView.text,text];
}

@end
