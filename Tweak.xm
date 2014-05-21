@interface MessageMegaMall : NSObject
-(id)tableIndexPathOfMessageOrConversation:(id)arg1;
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

%hook MailboxContentViewController
%new
-(void)updateTitleCount{
    int unreadCount = [[self mf_unreadCountForDisplay] integerValue];
    NSString* titleString = @"Inbox";
    if(unreadCount>0)
        [[self navigationItem] setTitle:[NSString stringWithFormat:@"%@ (%d)",titleString, unreadCount]];
    else
        [[self navigationItem] setTitle:[NSString stringWithFormat:@"%@",titleString]];
}
-(void)viewDidLoad{
    %orig;
    [self updateTitleCount];
}
-(void)_unreadCountChanged:(id)arg1{
    %orig;
    [self updateTitleCount];
}
%end

%hook MessageViewController
%new
-(void)updateTitleCount{
    MessageMegaMall* mall = MSHookIvar<MessageMegaMall*>(self,"_mall");
    MFMailMessage* message = MSHookIvar<MFMailMessage*>(mall,"_currentMessage");
    int index = ((NSIndexPath*)[mall tableIndexPathOfMessageOrConversation:message]).row +1;
    int total = [mall localMessageCount];
    [[self navigationItem] setTitle:[NSString stringWithFormat:@"%d of %d", index, total]];
}
-(void)displayMessage:(id)arg1 immediately:(BOOL)arg2{
    %orig;
    [self updateTitleCount];
}
-(void)unreadCountChanged:(id)arg1{
    %orig;
    [self updateTitleCount];
}
-(void)viewWillAppear:(BOOL)arg1{
    %orig;
    [self updateTitleCount];
}
%end


