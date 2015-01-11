#import "notify.h"

@interface MessageMegaMall : NSObject
-(id)flattenedIndexPathOfMessage:(id)arg1;
-(unsigned)unreadCountForDisplay;
-(unsigned)localMessageCount;
@end

@interface MFMailMessage : NSObject
@end

@interface MailboxContentViewController : NSObject
-(void)updateTitleCount;
-(id)navigationItem;
-(id)mf_unreadCountForDisplay;
@end

@interface MessageViewController : NSObject
-(void)updateTitleCount;
-(id)navigationItem;
-(void)setArrowsButtonItem:(id)arg1;
@end

@interface SBLockScreenViewController
-(BOOL)isPasscodeLockVisible;
@end

int isLocked(){
    int notification_token;
    uint64_t state;
    notify_register_check("com.apple.springboard.lockstate", &notification_token);
    notify_get_state(notification_token, &state);
    return state;
}

%group iPhoneHooks
%hook MailboxContentViewController
%new
-(void)updateTitleCount{
    int unreadCount = [[self mf_unreadCountForDisplay] integerValue];
    NSMutableString* titleString = [[NSMutableString alloc] init];
    [titleString setString: [[self navigationItem] title]];

    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\W\\(\\d*\\)"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:&error];
    [regex replaceMatchesInString:titleString options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, titleString.length) withTemplate:@""];

    if(unreadCount>0)
        [[self navigationItem] setTitle:[NSString stringWithFormat:@"%@ (%d)",titleString, unreadCount]];
    else
	[[self navigationItem] setTitle:[NSString stringWithFormat:@"%@",titleString]];
}
-(void)viewDidAppear{
    %orig;
    if(!isLocked())
	[self updateTitleCount];
}
-(void)_unreadCountChanged:(id)arg1{
    %orig;
    if(!isLocked())
	[self updateTitleCount];
}
%end

%hook MessageViewController
%new
-(void)updateTitleCount{
    MessageMegaMall* mall = MSHookIvar<MessageMegaMall*>(self,"_mall");
    MFMailMessage* message = MSHookIvar<MFMailMessage*>(mall,"_currentMessage");
    int index = ((NSIndexPath*)[mall flattenedIndexPathOfMessage: message]).row + 1;
    int total = [mall localMessageCount];
    [[self navigationItem] setTitle:[NSString stringWithFormat:@"%d of %d", index, total]];
}

-(void)displayMessage:(id)arg1 immediately:(BOOL)arg2{
    %orig;
    if(!isLocked())
	[self updateTitleCount];
}
-(void)unreadCountChanged:(id)arg1{
    %orig;
    if(!isLocked())
	[self updateTitleCount];
}
-(void)viewWillAppear:(BOOL)arg1{
    %orig;
    if(!isLocked())
	[self updateTitleCount];
}

%end
%end

%ctor{
  if ( [(NSString*)[objc_getClass("UIDevice") currentDevice].model hasPrefix:@"iPad"]) {
    //no ipad hooks currently
  }
  else{
    %init(iPhoneHooks);
  }
}
