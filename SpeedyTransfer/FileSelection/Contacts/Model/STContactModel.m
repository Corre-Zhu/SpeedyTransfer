//
//  STContactModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/19.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STContactModel.h"
#import <AddressBook/AddressBook.h>

@implementation STContactModel

+ (void)getContactsModelListWithCompletion:(GetContactsCompletionHandler)handler {
    CFErrorRef error;
    NSLog(@"1");
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
        if (granted) {
            NSLog(@"2");
            [STContactModel getContactsFromAddressBookWithCompletionHandler:handler];
        } else {
            handler(nil);
        }
    });
}

+ (void)getContactsFromAddressBookWithCompletionHandler:(GetContactsCompletionHandler)handler {
    CFErrorRef error = NULL;
    NSArray *contacts = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *mutableContacts = [NSMutableArray arrayWithCapacity:allContacts.count];
        NSUInteger i = 0;
        for (i = 0; i<[allContacts count]; i++)
        {
            STContactModel *contact = [[STContactModel alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            contact.recordId = ABRecordGetRecordID(contactPerson);

            // Get first and last names
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            
            // Set Contact properties
            NSMutableString *name = [NSMutableString string];
            if (lastName.length > 0) {
                [name appendString:lastName];
            }
            
            if (firstName.length > 0) {
                [name appendString:firstName];
            }
            contact.name = name;
            
            // Get mobile number
            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            contact.phone = [STContactModel getMobilePhoneProperty:phonesRef];
            if(phonesRef) {
                CFRelease(phonesRef);
            }
            
            if (contact.name.length == 0 && contact.phone.length == 0) {
                continue;
            }
            
            if (contact.name.length <= 0 && contact.phone.length > 0) {
                contact.name = [contact.phone copy];
            }
            
            // Get image if it exists
            NSData *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
            contact.image = [UIImage imageWithData:imgData];
            if (!contact.image) {
                contact.image = [UIImage imageNamed:@"phone_bg"];
            }
            
            [mutableContacts addObject:contact];
        }
        
        if(addressBook) {
            CFRelease(addressBook);
        }
        
        NSLog(@"3");

        if (mutableContacts.count > 0) {
            contacts = [STContactModel sortContacts:mutableContacts];
            
        }
        NSLog(@"4");

        handler(contacts);
    } else {
        handler(nil);
    }
}

+ (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if (CFStringGetLength(currentPhoneValue) > 0) {
            return (__bridge NSString *)currentPhoneValue;
        }
        
        if(currentPhoneLabel) {
            CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue) {
            CFRelease(currentPhoneValue);
        }
        
    }
    
    return nil;
}

+ (NSArray *)sortContacts:(NSMutableArray *)tempArray {
    if (tempArray.count == 0) {
        return nil;
    }
    
    [tempArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        STContactModel *model1 = obj1;
        STContactModel *model2 = obj2;
        if (model1.shortName.length == 0) {
            model1.shortName = [model1.name shortPinYin];
            if (model1.shortName.length == 0) {
                model1.shortName = model1.name;
            }
        }
        if (model2.shortName.length == 0) {
            model2.shortName = [model2.name shortPinYin];
            if (model2.shortName.length == 0) {
                model2.shortName = model2.name;
            }
        }
        
        return [model1.shortName compare:model2.shortName options:NSCaseInsensitiveSearch];
    }];
    
    NSMutableArray *othersArray = [NSMutableArray array];
    
    NSMutableArray *tempSectionArray = [NSMutableArray array];
    for (STContactModel *model in tempArray) {
        NSString *letter = nil;
        if ([model.shortName length] < 1) {
            letter = @"#";
        }else{
            int unicode = [model.shortName characterAtIndex:0];
            if ((unicode>= 0x41 && unicode<= 0x5a) || (unicode>= 0x61 && unicode<= 0x7a)) { //english alphabet
                letter = [[model.shortName substringToIndex:1] uppercaseString];
            }else{
                letter = @"#";
            }
        }
        
        if ([letter isEqualToString:@"#"]) {
            [othersArray addObject:model];
            continue;
        }
        
        NSDictionary *dic = tempSectionArray.lastObject;
        if (![dic.allKeys.firstObject isEqualToString:letter]) {
            dic = @{letter: [NSMutableArray array]};
            [tempSectionArray addObject:dic];
        }
        NSMutableArray *arr = dic.allValues.firstObject;
        [arr addObject:model];
    }
    
    if (othersArray.count > 0) {
        [tempSectionArray addObject:@{@"#": othersArray}];
    }
    
    return [NSArray arrayWithArray:tempSectionArray];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[STContactModel class]]) {
        return NO;
    }
    
    STContactModel *contact = object;
    if (self.recordId == contact.recordId) {
        return YES;
    }
    
    return NO;
}

@end
