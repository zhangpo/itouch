//
//  SWUIToolKit.m
//  Nurse
//
//  Created by Wu Stan on 12-4-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SWUIToolKit.h"
#import <CommonCrypto/CommonCrypto.h>
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonCrypto.h>
#import <AdSupport/AdSupport.h>

#pragma mark -
#pragma mark UILabel Catergory
@implementation UILabel(SWUIToolKit)

+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font{
    UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
    lbl.font = font;
    lbl.backgroundColor = [UIColor clearColor];
    
    return [lbl autorelease];
}

+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)color{
    UILabel *lbl = [self createLabelWithFrame:frame font:font];
    lbl.textColor = color;
    
    return lbl;
}

@end


#pragma mark -
#pragma mark SWTextView
@interface SWTextView ()
- (void)_initialize;
- (void)_updateShouldDrawPlaceholder;
- (void)_textChanged:(NSNotification *)notification;
@end


@implementation SWTextView {
    BOOL _shouldDrawPlaceholder;
}


#pragma mark Accessors

@synthesize placeholder = _placeholder;
@synthesize placeholderColor = _placeholderColor;

- (void)setText:(NSString *)string {
    [super setText:string];
    [self _updateShouldDrawPlaceholder];
}


- (void)setPlaceholder:(NSString *)string {
    if ([string isEqual:_placeholder]) {
        return;
    }
    
    [_placeholder release];
    _placeholder = [string retain];
    
    [self _updateShouldDrawPlaceholder];
}


#pragma mark NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
    
    [_placeholder release];
    [_placeholderColor release];
    [super dealloc];
}


#pragma mark UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self _initialize];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self _initialize];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_shouldDrawPlaceholder) {
        [_placeholderColor set];
        [_placeholder drawInRect:CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, self.frame.size.height - 16.0f) withFont:self.font];
    }
}


#pragma mark Private

- (void)_initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textChanged:) name:UITextViewTextDidChangeNotification object:self];
    
    self.placeholderColor = [UIColor colorWithWhite:0.702f alpha:1.0f];
    _shouldDrawPlaceholder = NO;
}


- (void)_updateShouldDrawPlaceholder {
    BOOL prev = _shouldDrawPlaceholder;
    _shouldDrawPlaceholder = self.placeholder && self.placeholderColor && self.text.length == 0;
    
    if (prev != _shouldDrawPlaceholder) {
        [self setNeedsDisplay];
    }
}


- (void)_textChanged:(NSNotification *)notificaiton {
    [self _updateShouldDrawPlaceholder];    
}

@end


#pragma mark -
#pragma mark    SWImageView
@implementation SWImageView
@synthesize delegate;

- (void)loadURL:(NSString *)str{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(str){
        NSArray *ary = [str componentsSeparatedByString:@"/"];
        NSMutableString *fileName = [NSMutableString string];
        
        for (int i=0;i<[ary count];i++)
            [fileName appendString:[ary objectAtIndex:i]];
        
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:path]){
            [self setImage:[UIImage imageWithContentsOfFile:path]];
            
            NSObject *obj = (NSObject *)delegate;
            if ([obj respondsToSelector:@selector(wImageViewLoadFinished:)])
                [delegate swImageViewLoadFinished:self];
        }else{
            [NSThread detachNewThreadSelector:@selector(loadImage:) toTarget:self withObject:str];
        }
        
    }
    
    [pool release];
}

- (void)loadImage:(NSString *)str{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSURL *url = [NSURL URLWithString:str];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [UIImage imageWithData:data];
    [self setImage:img];
    
    
    //save image
    NSArray *ary = [str componentsSeparatedByString:@"/"];
    NSMutableString *fileName = [NSMutableString string];
    
    for (int i=0;i<[ary count];i++)
        [fileName appendString:[ary objectAtIndex:i]];
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    [data writeToFile:path atomically:NO];
    
    
    
    NSObject *obj = (NSObject *)delegate;
    if ([obj respondsToSelector:@selector(wImageViewLoadFinished:)])
        [delegate swImageViewLoadFinished:self];
    
    [pool release];
}

- (void)dealloc{
    self.delegate = nil;
    
    [super dealloc];
}

@end


#pragma mark -
#pragma mark UIImage Category
@implementation UIImage(SWUIToolKit)

- (UIImage *)resizedImage:(CGSize)newSize{
    CGSize mysize = self.size;
    
    float w = newSize.width;
    float h = newSize.height;
    float W = mysize.width;
    float H = mysize.height;
    
    float fw = w/W;
    float fh = h/H;
    
    if (w>=W && h>=H){
        return self;
    }else{
        if (fw>fh){
            w = h/H*W;
        }else{
            h = w/W*H;
        }
    }
    
    UIImageView *imgv = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,w,h)] autorelease];
    [imgv setImage:self];
    
    UIGraphicsBeginImageContextWithOptions(imgv.bounds.size,YES,0.0);
    [imgv.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imgC = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imgC;
}

- (UIImage *)croppedImage:(CGRect)area{
    
    UIView *v = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, area.size.width, area.size.height)] autorelease];
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(-area.origin.x, -area.origin.y, self.size.width, self.size.height)];
    [imgv setImage:self];
    [v addSubview:imgv];
    [imgv release];
    
    imgv.frame = CGRectMake(-area.origin.x, -area.origin.y, imgv.frame.size.width, imgv.frame.size.height);
    
    
    UIGraphicsBeginImageContextWithOptions(v.bounds.size,YES,0.0);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imgC = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imgC;

}

@end


#pragma mark -
#pragma mark SWNavigationViewController

@implementation UINavigationBar (UINavigationBar_CustomBG)

- (void)drawRect:(CGRect)rect
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BSNavBG" ofType:@"png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    [image drawInRect:rect];
    [image release];
}

@end

@implementation SWNavigationViewController
@synthesize bShowTabBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:kNavBGName] forBarMetrics:UIBarMetricsDefault];
    }
    
    
    
    
    bShowTabBar = YES;
//    self.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    //    self.navigationBar.tintColor = [UIColor colorWithRed:233/255.0f green:133/255.0f blue:49 /255.0f alpha:1.0];
    self.delegate = self;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //    NSSet *setclass = [NSSet setWithObjects:NSStringFromClass([ABBlogDetailViewController class]),
    //                       NSStringFromClass([ABBindViewController class]),
    //                       NSStringFromClass([ABAboutViewController class]),
    //                       NSStringFromClass([ABAlbumViewController class]),
    //                       NSStringFromClass([ABWebViewController class]),
    //                       NSStringFromClass([ABStatusPictureViewController class]),
    //                       NSStringFromClass([ABPMViewController class]),
    //                       nil];
    //    
    //    if ([setclass containsObject:NSStringFromClass([viewController class])]){
    //        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTabBar" object:nil];
    //        bShowTabBar = NO;
    //    }
    //    else{
    //        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTabBar" object:nil];
    //        bShowTabBar = YES;
    //    }
}


@end


/*
#pragma mark -
#pragma mark SWLabel
@implementation SWLabel
@synthesize attString,images,imageInfos;

- (void)dealloc{
    self.attString = nil;
    self.text = nil;
    self.font = nil;
    self.imageInfos = nil;
    self.images = nil;
    
    [super dealloc];
}

- (void)refreshContent{
    MarkupParser *p = [[MarkupParser alloc] init];
    
    p.fontName = self.font.fontName;
    p.pointSize = self.font.pointSize;
    p.color = self.textColor;
    self.attString = [p attrStringFromMarkup:strText];
    self.imageInfos = p.images;
    
    [p release];
    
    [self setNeedsDisplay];
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont systemFontOfSize:17];
        self.textColor = [UIColor blackColor];
        self.images = [NSMutableArray array];
    }
    return self;
}

- (void)setText:(NSString *)text{
    if (strText!=text){
        [strText release];
        strText = [text copy];
    }
    
    if (strText){
        [self refreshContent];
    }
}

- (NSString *)text{
    return strText;
}

- (void)setFont:(UIFont *)font{
    if (fontLabel!=font){
        [fontLabel release];
        fontLabel = [font retain];
    }
    
    if (strText) {
        [self refreshContent];
    }
}

- (UIFont *)font{
    return fontLabel;
}

- (void)setTextColor:(UIColor *)color{
    if (textColor!=color){
        [textColor release];
        textColor= [color retain];
    }
    
    if (strText){
        [self refreshContent];
    }
}

- (UIColor *)textColor{
    return textColor;
}


- (void)attachImagesWithFrame:(CTFrameRef)f{
    //drawing images
    NSArray *lines = (NSArray *)CTFrameGetLines(f); //1
    
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(f, CFRangeMake(0, 0), origins); //2
    
    int imgIndex = 0; //3
    NSDictionary* nextImage = [self.imageInfos objectAtIndex:imgIndex];
    int imgLocation = [[nextImage objectForKey:@"location"] intValue];
    
    //find images for the current column
    CFRange frameRange = CTFrameGetVisibleStringRange(f); //4
    while ( imgLocation < frameRange.location ) {
        imgIndex++;
        if (imgIndex>=[self.imageInfos count]) return; //quit if no images for this column
        nextImage = [self.imageInfos objectAtIndex:imgIndex];
        imgLocation = [[nextImage objectForKey:@"location"] intValue];
    }
    
    NSUInteger lineIndex = 0;
    for (id lineObj in lines) { //5
        CTLineRef line = (CTLineRef)lineObj;
        
        for (id runObj in (NSArray *)CTLineGetGlyphRuns(line)) { //6
            CTRunRef run = (CTRunRef)runObj;
            CFRange runRange = CTRunGetStringRange(run);
            
            if ( runRange.location <= imgLocation && runRange.location+runRange.length > imgLocation ) { //7
	            CGRect runBounds;
	            CGFloat ascent;//height above the baseline
	            CGFloat descent;//height below the baseline
	            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL); //8
	            runBounds.size.height = ascent + descent;
                
	            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL); //9
	            runBounds.origin.x = origins[lineIndex].x  + xOffset;
	            runBounds.origin.y = origins[lineIndex].y;
	            runBounds.origin.y -= descent;
                
                UIImage *img = [UIImage imageWithContentsOfFile:[nextImage objectForKey:@"fileName"]];
                CGPathRef pathRef = CTFrameGetPath(f); //10
                CGRect colRect = CGPathGetBoundingBox(pathRef);
                
                CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                [self.images addObject: //11
                 [NSArray arrayWithObjects:img, NSStringFromCGRect(imgBounds) , nil]
                 ]; 
                //load the next image //12
                imgIndex++;
                if (imgIndex < [self.imageInfos count]) {
                    nextImage = [self.imageInfos objectAtIndex: imgIndex];
                    imgLocation = [[nextImage objectForKey: @"location"] intValue];
                }
                
            }
        }
        lineIndex++;
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (attString){
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, self.bounds);
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, NULL);
        
        if ([self.imageInfos count]>0)
            [self attachImagesWithFrame:frame];
        
        CTFrameDraw(frame, context);
        
        CFRelease(frame);
        CFRelease(path);
        CFRelease(framesetter);
        
        for (NSArray* imageData in self.images) {
            UIImage* img = [imageData objectAtIndex:0];
            CGRect imgBounds = CGRectFromString([imageData objectAtIndex:1]);
            CGContextDrawImage(context, imgBounds, img.CGImage);
        }
    
        CTTextAlignment alignment = kCTJustifiedTextAlignment;

        CTParagraphStyleSetting settings[] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
        };
        
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
        NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        (id)paragraphStyle, (NSString*)kCTParagraphStyleAttributeName,
                                        nil];
        
        NSMutableAttributedString* stringCopy = [[[NSMutableAttributedString alloc] initWithAttributedString:self.attString] autorelease];
        [stringCopy addAttributes:attrDictionary range:NSMakeRange(0, [attString length])];
        self.attString = (NSAttributedString*)stringCopy;
    }
}


- (void)sizeToFit{
    int i = 0;
    CGRect rect;
    BOOL needHeight = YES;
    while (needHeight) {
        i++;
        rect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, [self.text sizeWithFont:self.font].height*i);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, rect);
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attString);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attString length]), path, NULL);
        if (CTFrameGetVisibleStringRange(frame).length>=self.attString.length)
            needHeight = NO;
        CFRelease(path);
        CFRelease(framesetter);
        CFRelease(frame);
        
        if (!needHeight){
            if (1==i){
                BOOL needWidth = YES;
                float w = 0;
                while (needWidth) {
                    w++;
                    rect = CGRectMake(self.frame.origin.x, self.frame.origin.y,w, [self.text sizeWithFont:self.font].height);
                    CGMutablePathRef path = CGPathCreateMutable();
                    CGPathAddRect(path, NULL, rect);
                    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attString);
                    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attString length]), path, NULL);
                    if (CTFrameGetVisibleStringRange(frame).length>=self.attString.length)
                        needWidth = NO;
                    CFRelease(path);
                    CFRelease(framesetter);
                    CFRelease(frame);
                }
            }
        }
    }
    self.frame = rect;
}


@end


#pragma mark -  Markup Parser
@implementation MarkupParser

@synthesize fontName,pointSize,color,strokeColor,strokeWidth;
@synthesize images;

- (id)init
{
    self = [super init];
    if (self) {
        self.fontName = [UIFont systemFontOfSize:17].fontName;
        self.pointSize = [UIFont systemFontOfSize:17].pointSize;
        self.color = [UIColor blackColor];
        self.strokeColor = [UIColor clearColor];
        self.strokeWidth = 0.0;
        self.images = [NSMutableArray array];
    }
    return self;
}

- (NSAttributedString *)attrStringFromMarkup:(NSString*)markup
{
    NSMutableAttributedString* aString = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease]; //1
    
    NSRegularExpression* regex = [[NSRegularExpression alloc]
                                  initWithPattern:@"(.*?)(<[^>]+>|\\Z)"
                                  options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                  error:nil]; //2
    NSArray* chunks = [regex matchesInString:markup options:0
                                       range:NSMakeRange(0, [markup length])];
    [regex release];
    
    
    for (NSTextCheckingResult* b in chunks) {
        NSArray* parts = [[markup substringWithRange:b.range] componentsSeparatedByString:@"<"]; //1
        
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.fontName,self.pointSize, NULL);
        
        //apply the current text style //2
        NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               (id)self.color.CGColor, kCTForegroundColorAttributeName,
                               (id)fontRef, kCTFontAttributeName,
                               (id)self.strokeColor.CGColor, (NSString *) kCTStrokeColorAttributeName,
                               (id)[NSNumber numberWithFloat: self.strokeWidth], (NSString *)kCTStrokeWidthAttributeName,
                               nil];
        [aString appendAttributedString:[[[NSAttributedString alloc] initWithString:[parts objectAtIndex:0] attributes:attrs] autorelease]];
        
        CFRelease(fontRef);
        
        //handle new formatting tag //3
        if ([parts count]>1) {
            NSString* tag = (NSString*)[parts objectAtIndex:1];
            if ([tag hasPrefix:@"style"]) {
                //stroke color
                NSRegularExpression* scolorRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=strokeColor=\")\\w+" options:0 error:NULL] autorelease];
                [scolorRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    if ([[tag substringWithRange:match.range] isEqualToString:@"none"]) {
                        self.strokeWidth = 0.0;
                    } else {
                        self.strokeWidth = -3.0;
                        SEL colorSel = NSSelectorFromString([NSString stringWithFormat: @"%@Color", [tag substringWithRange:match.range]]);
                        self.strokeColor = [UIColor performSelector:colorSel];
                    }
                }];
                
                //color
                NSRegularExpression* colorRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=color=\")[^\"]+" options:0 error:NULL] autorelease];
                [colorRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    NSString *str = [tag substringWithRange:match.range];
                    if ([[str componentsSeparatedByString:@","] count]>1){
                        NSArray *ary = [str componentsSeparatedByString:@","];
                        if ([ary count]==4){
                            float r = [[ary objectAtIndex:0] floatValue];
                            float g = [[ary objectAtIndex:1] floatValue];
                            float b = [[ary objectAtIndex:2] floatValue];
                            float a = [[ary objectAtIndex:3] floatValue];
                            
                            self.color = [UIColor colorWithRed:r green:g blue:b alpha:a];
                        }
                    }else {
                        SEL colorSel = NSSelectorFromString([NSString stringWithFormat: @"%@Color", [tag substringWithRange:match.range]]);
                        self.color = [UIColor performSelector:colorSel]; 
                    }
                    
                }];
                
                //font
                NSRegularExpression* fontNameRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=fontName=\")[^\"]+" options:0 error:NULL] autorelease];
                [fontNameRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    self.fontName = [tag substringWithRange:match.range];
                }];
                
                NSRegularExpression* pointSizeRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=pointSize=\")[^\"]+" options:0 error:NULL] autorelease];
                [pointSizeRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    self.pointSize = [[tag substringWithRange:match.range] floatValue];
                }];
                
                
            } //end of font parsing
            
            if ([tag hasPrefix:@"img"]){
                __block NSNumber *width = [NSNumber numberWithInt:0];
                __block NSNumber *height = [NSNumber numberWithInt:0];
                __block NSString *fileName = @"";
                
                //width
                NSRegularExpression *widthRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=width=\")[^\"]+" options:0 error:NULL] autorelease];
                [widthRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match,NSMatchingFlags flags,BOOL *stop){
                    width = [NSNumber numberWithInt:[[tag substringWithRange:match.range] intValue]]; 
                }];
                
                //height
                NSRegularExpression *heightRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=height=\")[^\"]+" options:0 error:NULL] autorelease];
                [heightRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match,NSMatchingFlags flags,BOOL *stop){
                    height = [NSNumber numberWithInt:[[tag substringWithRange:match.range] intValue]]; 
                }];
                
                //image
                NSRegularExpression* srcRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=src=\")[^\"]+" options:0 error:NULL] autorelease];
                [srcRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    fileName = [tag substringWithRange: match.range];
                }];
                
                if ([width intValue]==0 || [height intValue]==0){
                    UIImage *img = [UIImage imageWithContentsOfFile:fileName];
                    float w = img.size.width;
                    float h = img.size.height;
                    
                    float H = self.pointSize;
                    float W = H/h*w;
                    
                    width = [NSNumber numberWithInt:W];
                    height = [NSNumber numberWithInt:H];
                }
                
                //add the image for drawing
                [self.images addObject:
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  width,@"width",
                  height,@"height",
                  fileName,@"fileName",
                  [NSNumber numberWithInt:[aString length]],@"location",
                  nil]];
                
                //render empty space for drawing the image in the text
                CTRunDelegateCallbacks callbacks;
                callbacks.version = kCTRunDelegateVersion1;
                callbacks.getAscent = ascentCallback;
                callbacks.getDescent = descentCallback;
                callbacks.getWidth = widthCallback;
                callbacks.dealloc = deallocCallback;
                
                NSDictionary *imgAttr = [[NSDictionary dictionaryWithObjectsAndKeys:width,@"width",height,@"height",nil] retain];
                
                CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks,imgAttr);
                NSDictionary *attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:(id)delegate,(NSString *)kCTRunDelegateAttributeName,(id)[UIColor clearColor].CGColor,kCTForegroundColorAttributeName, nil];
                
                //add a space to the text so that it can call the delegate
                [aString appendAttributedString:[[[NSAttributedString alloc] initWithString:@"a" attributes:attrDictionaryDelegate] autorelease]];
            }
        }
    }
    
    return (NSAttributedString*)aString;
}

// Callbacks
static void deallocCallback(void *ref){
    [(id)ref release];
}

static CGFloat ascentCallback(void *ref){
    return [(NSString *)[(NSDictionary *)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref){
    return [(NSString *)[(NSDictionary *)ref objectForKey:@"descent"] floatValue];
}

static CGFloat widthCallback(void *ref){
    return [(NSString *)[(NSDictionary *)ref objectForKey:@"width"] floatValue];
}

-(void)dealloc
{
    self.fontName = nil;
    self.color = nil;
    self.strokeColor = nil;
    self.images = nil;
    
    [super dealloc];
}


@end
*/


#pragma mark -  UIAlertView Extensions
@implementation UIAlertView(SWExtensions)

+ (void)showAlertWithTitle:(NSString *)strtitle message:(NSString *)strmessage cancelButton:(NSString *)strcancel{
    [UIAlertView showAlertWithTitle:strtitle message:strmessage cancelButton:strcancel delegate:nil];
}

+ (void)showAlertWithTitle:(NSString *)strtitle message:(NSString *)strmessage cancelButton:(NSString *)strcancel delegate:(id<UIAlertViewDelegate>)alertdelegate{
    if (!strcancel)
        strcancel = @"确定";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strtitle message:strmessage delegate:alertdelegate cancelButtonTitle:strcancel otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end

#pragma mark - UIImage Extensions
@implementation UIImage(SWExtensions)

+ (UIImage *)image:(UIImage *)img forTintColor:(UIColor *)color{
    CGImageRef imageRef = img.CGImage;

    size_t width                    = CGImageGetWidth(imageRef);
    size_t height                   = CGImageGetHeight(imageRef);
    size_t bitsPerComponent         = CGImageGetBitsPerComponent(imageRef);
    size_t bitsPerPixel             = CGImageGetBitsPerPixel(imageRef);
    size_t bytesPerRow              = CGImageGetBytesPerRow(imageRef);
    
    if (bitsPerPixel!=32)
        return img;
    
    float r,g,b,a;
    int ncoms = CGColorGetNumberOfComponents(color.CGColor);
    const float *fc = CGColorGetComponents(color.CGColor);
    if (2==ncoms){
        r = g = b = fc[0];
        a = fc[1];
    }else if (4==ncoms){
        r = fc[0];
        g = fc[1];
        b = fc[2];
        a = fc[3];
    }
    

    NSData *data = (NSData *)CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
    unsigned char *pixels = (unsigned char *)[data bytes];
    
    // this is where you manipulate the individual pixels
    // assumes a 4 byte pixel consisting of rgb and alpha
    // for PNGs without transparency use i+=3 and remove int a
    for(int i = 0; i < [data length]; i += 4)
    {
        int ri = i;
        int gi = i+1;
        int bi = i+2;
        int ai = i+3;
        
        if (pixels[ai]!=0){
            pixels[ri]   = r*255;
            pixels[gi]   = g*255;
            pixels[bi]   = b*255;
//            pixels[ai]   = a*255;
        }
    }
    
    // create a new image from the modified pixel data
    
    
    CGColorSpaceRef colorspace      = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo         = CGImageGetBitmapInfo(imageRef);
    CGDataProviderRef provider      = CGDataProviderCreateWithData(NULL, pixels, [data length], NULL);
    
    CGImageRef newImageRef = CGImageCreate (
                                            width,
                                            height,
                                            bitsPerComponent,
                                            bitsPerPixel,
                                            bytesPerRow,
                                            colorspace,
                                            bitmapInfo,
                                            provider,
                                            NULL,
                                            false,
                                            kCGRenderingIntentDefault
                                            );
    // the modified image
    UIImage *newImage   = [UIImage imageWithCGImage:newImageRef scale:2 orientation:UIImageOrientationUp];
    
    // cleanup
    [data release];
    CGColorSpaceRelease(colorspace);
    CGDataProviderRelease(provider);
    CGImageRelease(newImageRef);
    
    return newImage;
}

- (UIImage *)tintColorImage:(UIColor *)color{
    return [UIImage image:self forTintColor:color];
}

@end

@implementation NSString(UIKitUtil)

-(NSString *)MD5
{
	unsigned char hashBytes[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self UTF8String], [self length], hashBytes);
	
    //	for (int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    //		printf("%x",hashBytes[i]);
    
	NSMutableString *mutStr = [[NSMutableString alloc] init];
	for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
	{
		NSString *a = [NSString stringWithFormat:@"%x",hashBytes[i]];
		[mutStr appendString:a];
	}
	
	return [mutStr autorelease];
}

+ (NSString *)UUIDString{
    NSString *uuid = nil;
    if ([UIDevice currentDevice].systemVersion.floatValue>=7.0){
        uuid = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
    }else{
        uuid = [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
    }
    return uuid;
}

@end