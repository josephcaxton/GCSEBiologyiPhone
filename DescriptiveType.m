//
//  DescriptiveType.m
//  Evaluator
//
//  Created by Joseph caxton-Idowu on 26/10/2010.
//  Copyright 2010 caxtonidowu. All rights reserved.
//

#import "DescriptiveType.h"
#import "DescriptiveType1.h"
#import "TransparentToolBar.h"


@implementation DescriptiveType

@synthesize QuestionTemplate, SelectedTopic;  //, QuestionHeaderBox; //Search;  //QuestionItemBox
@synthesize  fileList, FileListTable, DirLocation,SFileName;
@synthesize  SFileName_Edit,QItem_Edit,QItem_View,AnswerObjects,Answer1,ShowCorrectAnswer,ShowAnswer,ShowAnswerHere,Continue,WebControl,Instruction;

int AnswerShown= 0;
static UIWebView *QuestionHeaderBox = nil;
#pragma mark -
#pragma mark View lifecycle

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 470

- (void)viewDidLoad {
    [super viewDidLoad];
	
    //To fix ios7 extending edges
    if([UIViewController instancesRespondToSelector:@selector(edgesForExtendedLayout)]){
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    

	
	AnswerShown = 0;
	if (!QuestionHeaderBox) {
		
	QuestionHeaderBox =[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 300)];
	
	}
	QuestionHeaderBox.scalesPageToFit = YES;
	
	self.FileListTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 160, SCREEN_WIDTH, SCREEN_HEIGHT - 170) style:UITableViewStyleGrouped];
	FileListTable.delegate = self;
	FileListTable.dataSource = self;
	//FileListTable.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    
    [self.FileListTable setBackgroundView:nil];
    NSString *BackImagePath = [[NSBundle mainBundle] pathForResource:@"back320x450" ofType:@"png"];
	UIImage *BackImage = [[UIImage alloc] initWithContentsOfFile:BackImagePath];
    self.FileListTable.backgroundColor = [UIColor colorWithPatternImage:BackImage];
	
	
	// Now I have added 1000 pdfs to the bundle. App is now ver slow
	// I don't need this to go live, it is just for admin only so i comment out CheckExistingFiles
	//CheckExistingFiles *ExistingFiles = [[CheckExistingFiles alloc]init];
	//NSArray *lists = ExistingFiles.ListofPdfsNotInDataBase;
	
	//self.fileList = lists;     
	
	//if ([fileList count ]  > 0) {
		
	//	NSString *FullFileName = [NSString stringWithFormat:@"%@",[fileList objectAtIndex:0]];
	//	[self setSFileName:[FullFileName lastPathComponent]];
		
		
	//}
	
	
	if (QItem_Edit != nil || QItem_View != nil) {
		// this means we are not in edit mode. we are in create mode.
		
		if (QItem_Edit) {
		
		NSString *result = [NSString stringWithFormat:@"%@",[QItem_Edit Question]];
		SFileName_Edit = result;
			
		UIBarButtonItem *NextButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style: UIBarButtonItemStyleBordered target:self action:@selector(Edit:)];
		self.navigationItem.rightBarButtonItem = NextButton;
		
		}
		else
		{
			// This is QItem_View  : View Mode
			NSString *result = [NSString stringWithFormat:@"%@",[QItem_View Question]];
			SFileName_Edit = result;
			
			AnswerObjects=  [[NSMutableArray alloc] initWithArray:[[QItem_View Answers1] allObjects]];
			
			CGRect frame = CGRectMake(5, 5, 290, 140);
			self.Answer1 =[[UITextView alloc] initWithFrame:frame];
			
            if(!ShowAnswer){
                // create a toolbar where we can place some buttons
                TransparentToolBar* toolbar = [[TransparentToolBar alloc]
                                               initWithFrame:CGRectMake(250, 0, 200, 45)];
                
                
                
                // create an array for the buttons
                NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
                
                UIBarButtonItem *SendSupportMail = [[UIBarButtonItem alloc] initWithTitle:@"Report Problem" style: UIBarButtonItemStyleBordered target:self action:@selector(ReportProblem:)];
                
                [buttons addObject:SendSupportMail];
                
                
                // create a spacer between the buttons
                UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil
                                           action:nil];
                [buttons addObject:spacer];
                
                
                
                
                
                UIBarButtonItem *EndTestnow = [[UIBarButtonItem alloc] initWithTitle:@"Stop Test" style: UIBarButtonItemStyleBordered target:self action:@selector(StopTest:)];
                
                
                [buttons addObject:EndTestnow];
                
                
                
                [toolbar setItems:buttons animated:NO];
                
                // place the toolbar into the navigation bar
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                          initWithCustomView:toolbar];
            }
            
			
			
		}
		
		
		
		[self loadDocument:[SFileName_Edit stringByDeletingPathExtension] inView:QuestionHeaderBox];
	}
	
	else{
		
		
		UIBarButtonItem *NextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style: UIBarButtonItemStyleBordered target:self action:@selector(Next:)];
		
		self.navigationItem.rightBarButtonItem = NextButton;
		
		[self loadDocument:[SFileName stringByDeletingPathExtension] inView:QuestionHeaderBox];
	}
	
	[self.view addSubview:QuestionHeaderBox];
	
	[self.view addSubview:FileListTable];
}

-(void)viewWillAppear:(BOOL)animated{
	
	[self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:1];
}
-(IBAction)NextQuestion:(id)sender{
	
	
	if (AnswerShown == 0) {
	
	NSArray *DirDomain = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DocumentsDirectory = [DirDomain objectAtIndex:0];
	NSString *XmlFileLocation = [DocumentsDirectory stringByAppendingString:@"/DecriptiveAnswers.xml"];
	
	
	// Get the Date 
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *now = [formatter stringFromDate:[NSDate date]];
	NSString *TextStart = @"\n\t<Result Date = ";
	NSString *Date = [NSString stringWithFormat:@"\"%@\"" ,now];
	NSString *DateEnd =@">";
	
	// Question and Answer
	
	NSString *QuestionTextStart = @"\n\t<Question No = ";
	NSString *QuestionTextData = [NSString stringWithFormat:@"\"%@\" ", [QItem_View Question]];
	NSString *AnswerTextStart = @"Answer = ";
	NSString *AnswerTextData = [NSString stringWithFormat:@"\"%@\" ", Answer1.text];
	NSString *QuestionTextEnd =@"/>";
	NSString *TextEnd = @"\n\t</Result>";
	NSString *CloseResultsData = @"\f</ResultsData﻿>﻿﻿";
	NSString *FinalText = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@",TextStart,Date,DateEnd,QuestionTextStart,QuestionTextData,AnswerTextStart,AnswerTextData,QuestionTextEnd,TextEnd,CloseResultsData];
	
	
	// Write to file
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath: XmlFileLocation];
	NSData *Str = [FinalText dataUsingEncoding:NSUTF16StringEncoding];
	
	// Locate a position before </ResultsData>
	unsigned long long Location = [fileHandle seekToEndOfFile];
	unsigned long long NewLocation = Location - 34;
	[fileHandle seekToFileOffset:NewLocation];
	
	//Write to the file and close	
	[fileHandle writeData:Str];
	[fileHandle closeFile];
		
	}
	
	[self.navigationController popViewControllerAnimated:YES];
		
	}


-(IBAction)Next:(id)sender{
	
	DescriptiveType1 *D_view1 = [[DescriptiveType1 alloc] initWithNibName:nil bundle:nil];
	
	
	D_view1.QuestionTemplate = self.QuestionTemplate;
	D_view1.SelectedTopic = self.SelectedTopic;
	D_view1.SFileNameValue = self.SFileName;
	
	[self.navigationController pushViewController:D_view1 animated:YES];
	
	
	
}

-(IBAction)Edit:(id)sender{
	
	DescriptiveType1 *D_view1 = [[DescriptiveType1 alloc] initWithNibName:nil bundle:nil];
	
	D_view1.QItem_ForEdit = QItem_Edit;
	
	
	
	[self.navigationController pushViewController:D_view1 animated:YES];
	
	
	
}

-(IBAction)Cancel:(id)sender{
	
	//[self dismissModalViewControllerAnimated:YES];
}

/*-(void)CheckAppDirectory:(NSString *)Location{
	
	NSFileManager *FM = [NSFileManager defaultManager];
	BOOL isDir = YES;
	
	if (![FM fileExistsAtPath:Location isDirectory:&isDir]) {
		NSError **error = nil;
		if (![FM createDirectoryAtPath:Location withIntermediateDirectories:YES attributes:nil error:error]) {
			
			NSLog(@"Error: Create folder failed Reason: %@",error);
			
		}
	}
	
}*/

-(IBAction)ShowCorrectAnswer:(id)sender{
	
	if (AnswerShown == 0) {
		
		AnswerShown = 1;
	
	//NSString *ExistingText =[[NSString alloc] initWithString: Answer1.text];
	//Answer1.text = nil;
		
	NSMutableString *Answer = [[AnswerObjects objectAtIndex:0] valueForKey:@"AnswerText"];
	NSMutableString *Reason = [[AnswerObjects objectAtIndex:0] valueForKey:@"Reason"];
        
		NSMutableString *FormatedString = [[NSMutableString alloc]initWithString:@"<p><font size =\"2\" face =\"times new roman \"> "];
		[FormatedString appendString:@"<h3>Suggested Answer(s) (For revision only)</h3>\n"];
		[FormatedString appendString:Answer];
        [FormatedString appendFormat:@"<br/>"];
        if([Reason isEqualToString:@"(null)"] || !Reason) {
            
        }
        else 
        { 
            
            [FormatedString appendString:Reason]; 
            
        }
        

		//[FormatedString appendString:@"\n<h4><u>End of Suggested Answer</u></h4>\n"];
		//[FormatedString appendString:@"<h4><u>Your Answer</u></h4>\n"];
		//[FormatedString appendString:ExistingText];
		[FormatedString appendString:@"</font></p>"];
		
		WebControl = [[UIWebView alloc]initWithFrame:CGRectMake(0,0,300,150)];
        WebControl.dataDetectorTypes = 0;
		[WebControl setBackgroundColor:[UIColor clearColor]];
		[WebControl loadHTMLString:FormatedString baseURL:nil];
		[Answer1 addSubview:WebControl];
		
	//[ExistingText release];
	[self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:1];
			
		
	
	}
	else {
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		CGRect rect = self.view.frame;
		rect.origin.y = 0;
		rect.size.height = 450;
		self.view.frame = rect;
		[UIView commitAnimations];
	}

}

/*-(IBAction)AddNewLine:(id)sender{
	
	// This is to fix iphone limitation on the use of keyboard, Add new line to a UItextView
	NSString *ExistingText =[[NSString alloc] initWithString: Answer1.text];
	Answer1.text = nil;
	
	NSString *NewLine =@"\n";
	NSString *AddToText = [ExistingText stringByAppendingString:NewLine];
	Answer1.text = AddToText;
	
	[ExistingText release];
}
*/

/*-(NSString *) getApplicationDirectory{
	
	
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *result = [documentsDirectory stringByAppendingString:@"/Evaluator_Questions/Data"];
	return result; 
	
	
	
}*/

-(IBAction)ReportProblem:(id)sender{
	
	if ([MFMailComposeViewController canSendMail]) {
		
		NSArray *SendTo = [NSArray arrayWithObjects:@"Support@LearnersCloud.com",nil];
		
		MFMailComposeViewController *SendMailcontroller = [[MFMailComposeViewController alloc]init];
		SendMailcontroller.mailComposeDelegate = self;
		[SendMailcontroller setToRecipients:SendTo];
		[SendMailcontroller setSubject:[NSString stringWithFormat:@"Ref %@ problem biology question detected on IPhone/IPod",[[NSString stringWithFormat:@"%@",QItem_View.Question] stringByDeletingPathExtension]]];
		
		
		[SendMailcontroller setMessageBody:[NSString stringWithFormat:@"Question Number %@ -- \n Add your message below ", [[NSString stringWithFormat:@"%@",QItem_View.Question] stringByDeletingPathExtension]] isHTML:NO];
		[self presentModalViewController:SendMailcontroller animated:YES];
		
	}
	
	else {
		UIAlertView *Alert = [[UIAlertView alloc] initWithTitle: @"Cannot send mail" 
														message: @"Device is unable to send email in its current state. Configure email" delegate: self 
											  cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		
		
		[Alert show];
		
	}
	
	
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
	
	
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
	
	
	
	
}


-(void)loadDocument:(NSString*)documentName inView:(UIWebView*)webView{
	
    
	NSString *path = [[NSBundle mainBundle] pathForResource:documentName ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
	
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait ) {
		
		QuestionHeaderBox.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 300);
		self.FileListTable.frame = CGRectMake(0, 160, SCREEN_WIDTH, SCREEN_HEIGHT - 170);
		//newLine.frame = CGRectMake(340, 0, 80, 30);
		ShowAnswerHere.frame = CGRectMake(15,0,138,38);
		Continue.frame = CGRectMake(165,0,138,38);
	}
	
	else {
		
		QuestionHeaderBox.frame = CGRectMake(80, 0, SCREEN_HEIGHT - 122, 160);
		self.FileListTable.frame = CGRectMake(0, 160, SCREEN_HEIGHT + 30, SCREEN_HEIGHT - 160);
		//newLine.frame = CGRectMake(340, 0, 80, 30);
		ShowAnswerHere.frame = CGRectMake(15,0,138,38);
		Continue.frame = CGRectMake(165,0,138,38);
	}
	
	
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSString *title;
	
	if (QItem_View) {
		
		title = @"";
	}
	else {
		
		title = @"Available Files";
	}
	
	return title; 
	
	
	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	 NSInteger count;
	
	if (QItem_View){
		
		count = [AnswerObjects count]  + 1;
		
	}
	else {
		
		count = [fileList count];
	}
	
	return count; 
	
	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
	tableView.allowsSelection = NO;
    
	if (QItem_Edit != nil) {
		// We are in edit mode here so don't show any row
		if (indexPath.row == 0) {
			cell.textLabel.text =@"You can't select file in edit mode";
		}
		return cell;
		
	}
	
	 else if (QItem_View !=nil ) {
		 
		 if (indexPath.row == 0) {
			 
             Instruction = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 600, 40)];
             Instruction.font = [UIFont boldSystemFontOfSize: 12.0];
             Instruction.textColor = [UIColor purpleColor];
             Instruction.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
             Instruction.backgroundColor = [UIColor clearColor];
             Instruction.numberOfLines=0;
             
             
             Instruction.text = @"You cannot type into this box. \n Work out your answer and press Show Answer ";
             
             [Answer1 addSubview:Instruction];
		 
		 Answer1.editable = NO;
		 //Answer1.delegate = self;
//		 Answer1.textColor = [UIColor blackColor];
//		 
//		 Answer1.autocorrectionType =UITextAutocorrectionTypeYes;
//		 Answer1.textAlignment = UITextAlignmentLeft;
//		 Answer1.tag = indexPath.row;
//		 Answer1.returnKeyType = UIReturnKeyDone;
		
		 [cell.contentView addSubview:Answer1];
			 if (ShowAnswer) {
				 [self ShowCorrectAnswer:self];
				 
			 }
		 
		 return cell;
		 }
		 else {
			 
			 NSString *ShowAnswerImageLocation = [[NSBundle mainBundle] pathForResource:@"btn_show_answer" ofType:@"png"];
             UIImage *ShowAnswerImage = [[UIImage alloc] initWithContentsOfFile:ShowAnswerImageLocation];
             
			 ShowAnswerHere = [UIButton buttonWithType:UIButtonTypeCustom];
             [ShowAnswerHere setImage:ShowAnswerImage forState:UIControlStateNormal];
             
             NSString *ContinueImageLocation = [[NSBundle mainBundle] pathForResource:@"btn_continue" ofType:@"png"];
             UIImage *ContinueImage = [[UIImage alloc] initWithContentsOfFile:ContinueImageLocation];
			 
             Continue = [UIButton buttonWithType:UIButtonTypeCustom];
             [Continue setImage:ContinueImage forState:UIControlStateNormal];
			 
			 if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ){
				 
				 //newLine.frame = CGRectMake(340, 0, 80, 30); // no space so this is not showing
                 ShowAnswerHere.frame = CGRectMake(15,0,138,38);
				 Continue.frame = CGRectMake(165,0,138,38);
			 }
			 else {
				 //newLine.frame = CGRectMake(340, 0, 80, 30);
				 ShowAnswerHere.frame = CGRectMake(15,0,138,38);
				 Continue.frame = CGRectMake(165,0,138,38);
			 }
			 
			 
			//[Continue setTitle:@"Continue" forState:UIControlStateNormal];
			 [Continue addTarget:self action:@selector(NextQuestion:) forControlEvents:UIControlEventTouchUpInside];
			 [cell addSubview:Continue];
			 
			 
			 
			 //[ShowAnswerHere setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
			 //[ShowAnswerHere setTitle:@"Show Answer" forState:UIControlStateNormal];
			 [ShowAnswerHere addTarget:self action:@selector(ShowCorrectAnswer:) forControlEvents:UIControlEventTouchUpInside];
			 [cell addSubview:ShowAnswerHere];
			 
			 //[newLine setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
			 //[newLine setTitle:@"New Line" forState:UIControlStateNormal];
			 //[newLine addTarget:self action:@selector(AddNewLine:) forControlEvents:UIControlEventTouchUpInside];
			  cell.selectionStyle = UITableViewCellSelectionStyleNone;
			 //[cell addSubview:newLine];
			 
			 if (ShowAnswer) {
				 cell.textLabel.text =@"";
				 //newLine.hidden = YES;
				 ShowAnswerHere.hidden = YES;
				 Continue.hidden = YES;
			 }
			 else {
				 //cell.textLabel.text =@"No Marks";
				 //newLine.hidden = NO;
				 ShowAnswerHere.hidden = NO;
				 Continue.hidden = NO;
			 }
			 
			 
			 return cell;
		 }

		 
	 }
	
	else
	{
		NSString *FileName = [NSString stringWithFormat:@"%@",[fileList objectAtIndex:indexPath.row]];
		cell.textLabel.text = [FileName lastPathComponent];
		return cell;
		
	}
	
	
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if ( !QItem_Edit   && !QItem_View  && ShowAnswer != YES){
		//not in edit mode
		
		NSString *FullFileName = [NSString stringWithFormat:@"%@",[fileList objectAtIndex:indexPath.row]];
		[self setSFileName:FullFileName];
		
		
		[self loadDocument:[SFileName stringByDeletingPathExtension] inView:QuestionHeaderBox];
	}
	
	
	
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect rect = self.view.frame;
	rect.origin.y = -170;
	rect.size.height = 690;
	self.view.frame = rect;
	[UIView commitAnimations];
	
	
	
}




/*- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        
        [Answer1 resignFirstResponder];
		// return screen to where is should be
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		CGRect rect = self.view.frame;
		rect.origin.y = 0;
		rect.size.height = 450;
		self.view.frame = rect;
		[UIView commitAnimations];
		
		
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
} */

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (QItem_View) {
		if (indexPath.row == 0){
			
		return 150;
		}
		else {
			return 40;
		}

	}
	return 50;
}

-(IBAction)StopTest:(id)sender {
    
    EvaluatorAppDelegate *appDelegate = (EvaluatorAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.FinishTestNow = YES;
    [self NextQuestion:nil];
}



#pragma mark -
#pragma mark Memory management


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	QuestionHeaderBox = nil;
}




@end
