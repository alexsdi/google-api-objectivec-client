//
//  AsyncImageView.m
//  ITDealer
//
//  Created by Administrator on 29/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SDIAsyncImageView.h"
#import "defs.h"
#import "UIImageExtras.h"


#ifdef WITHOUT_ARC
#define Destroy(x)  if(x!=nil){if([x respondsToSelector:@selector(retainCount)] && [x retainCount]>0){[x release];}x=nil;}
#else
#define Destroy(x) x=nil;
#endif


///#define WITHOUT_ARC
@implementation SDIAsyncImageDownloader
@synthesize delegate;

-(id)init
{
    self=[super init];
    if(self)
    {
#ifdef WITHOUT_ARC
        Destroy(strLocalFilePath);
#endif
        connection=nil;
        data=nil;
    }
    return self;
}
-(void)DownloadImageForURL:(NSString *)imageURL
{
    // NSLog(@"URL:%@",imageURL);
    
    NSString *lpath =[imageURL lastPathComponent];
    strLocalFilePath =[[NSString alloc] initWithFormat:@"%@/%@",[SDIAsyncImageView GetCatchPath],lpath];
#ifdef WITHOUT_ARC
    if (connection!=nil && [connection respondsToSelector:@selector(retainCount)])
#else
        if (connection!=nil)
#endif
        {
            
            [connection cancel];
            //[connection release];
        }
    //in case we are downloading a 2nd image
    if (data!=nil)
    {
#ifdef WITHOUT_ARC
        [data release];
#else
        data=nil;
#endif
    }
    MQ_
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; //notice how delegate set to self object
    
    if(connection!=nil)
    {
        /*
         if(shouldShowLoader==YES)
         {
         [self performSelectorOnMainThread:@selector(HidProgressBar) withObject:nil waitUntilDone:YES];
         HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
         HUD.mode=MBProgressHUDModeAnnularDeterminate;
         
         }
         */
        data = [[NSMutableData alloc] init];
    }
    _MQ
}
-(void)connection:(NSURLConnection *)Mconnection didFailWithError:(NSError *)error
{
    if(delegate && [delegate respondsToSelector:@selector(asyncconnection:didFailWithError:)])
    {
        [delegate asyncconnection:Mconnection didFailWithError:error];
    }
    connection=nil;
}
-(void) connection :(NSURLConnection *) Mconnection
 didReceiveResponse:(NSURLResponse *) response
{
    if(delegate && [delegate respondsToSelector:@selector(asyncConnection:didReceiveResponse:)])
    {
        [delegate asyncConnection:Mconnection didReceiveResponse:response];
    }
    // NSLog(@"download response");
}
//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    
    if (data==nil) { data = [[NSMutableData alloc] init]; }
    [data appendData:incrementalData];
    
    if(delegate && [delegate isKindOfClass:[SDIAsyncImageView class]] && [delegate respondsToSelector:@selector(asyncConnection:didReceiveData:)])
    {
        [delegate asyncConnection:theConnection didReceiveData:incrementalData];
    }
    
    
    
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    //so self data now has the complete image
    
    
    
    if(data!=nil && data.length>1260)
    {
        UIImage *mg=[UIImage imageWithData:data];
        if(mg==nil)
        {
            [delegate asyncconnection:connection didFailWithError:nil];
        }
        else
        {
            
            //if(mg.size.width >300 || mg.size.height>300)
            //    mg=[mg ScaleImageToRect:mg displaySize:CGSizeMake(800, 600)];
            
            NSData *newData=UIImageJPEGRepresentation(mg,1);
            if(newData!=nil)
                [newData writeToFile:strLocalFilePath atomically:YES];
            else
                [data writeToFile:strLocalFilePath atomically:YES];
            
            [delegate asyncImageDownloader:self didcompletedWithLocalURL:strLocalFilePath];
            
        }
        
        Destroy(data);
        
        data=nil;
        
    }
    connection=nil;
    //NSLog(@"end");
    
    
}
-(void)CancelDownload
{
    if(connection)
    {
        // NSLog(@"Cancelled");
        [connection cancel]; //in case the URL is still downloading
        
        Destroy(connection)
        
    }
    else
        NSLog(@"Not Cancelled");
}


- (void)dealloc {
    if(connection)
    {
        [connection cancel]; //in case the URL is still downloading
        
        Destroy(connection)
        
    }
    Destroy(data);
    Destroy(strLocalFilePath)
#ifdef WITHOUT_ARC
    [super dealloc];
#endif
}

@end

static SDIAsyncImageDownloadManager *_defaultManger=nil;

@implementation SDIAsyncImageDownloadManager

+(id)defaultManager
{
    if(_defaultManger==nil)
    {
        _defaultManger=[[SDIAsyncImageDownloadManager alloc]init];
    }
    return _defaultManger;
}
-(void)LoadCatche
{
    dicCatache=[[NSMutableDictionary alloc] init];
    dicCatacheDelegate=[[NSMutableDictionary alloc] init];
    dicCatacheUDID=[[NSMutableDictionary alloc] init];
}

-(void)DownloadImageForURL:(NSString *)strURL withDelegate:(id<SDIAsyncImageDownloaderDelegate>)delegate andUDID:(NSString *)stUDIDKey
{
    if(strURL!=nil && strURL.length>0 && stUDIDKey!=nil)
    {
        
        NSString *lpath =[strURL lastPathComponent];
        [dicCatacheDelegate setValue:lpath forKey:stUDIDKey];
        [dicCatache setValue:delegate forKey:stUDIDKey];
        [dicCatacheUDID setValue:stUDIDKey forKey:lpath];
        
        
        SDIAsyncImageDownloader *downloader =[[SDIAsyncImageDownloader alloc]init];
        [downloader setDelegate:self];
        [downloader DownloadImageForURL:strURL];
        //[arrDownloader addObject:downloader];
#ifdef WITHOUT_ARC
        [downloader release];
#endif
        downloader=nil;
        
    }
    
}

-(void)RemoveDelegate:(id<SDIAsyncImageDownloaderDelegate>)delegate
{
    
}
/*
 -(void)asyncImageDownloader:(AsyncImageDownloader *)asimage didcompletedWithLocalURL:(NSString *)strURL
 {
 
 
 NSString *cpath =[strURL lastPathComponent];
 
 NSString *stUDID =[dicCatacheUDID objectForKey:cpath];
 BOOL isValidUpdate=NO;
 if(stUDID!=nil && [stUDID isKindOfClass:[NSString class]])
 {
 NSString *strOldPath =[dicCatache objectForKey:stUDID];
 
 if(strOldPath!=nil && [strOldPath isEqualToString:cpath])
 {
 [dicCatache removeObjectForKey:stUDID];
 [dicCatacheUDID removeObjectForKey:cpath];
 [dicCatacheDelegate removeObjectForKey:stUDID];
 
 
 isValidUpdate=YES;
 id<AsyncImageDownloaderDelegate> mdelegate =[dicCatacheDelegate objectForKey:stUDID];
 if(mdelegate && [mdelegate respondsToSelector:@selector(asynchImageView:didCachedImage:)])
 {
 
 [mdelegate asynchImageView:self didCachedImage:strURL];
 }
 }
 }
 
 if(isValidUpdate==NO)
 NSLog(@"Older download");
 
 
 
 
 }
 */
@end

@implementation SDIAsyncImageView (cache)
static NSString *strCachePath=nil;

+(NSString *)GetCatchPath
{
    if(strCachePath==nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *categoryFolder =[NSString stringWithFormat:@"%@/BridgeImages",documentsDirectory];
        BOOL isDir=YES;
        if(![[NSFileManager defaultManager] fileExistsAtPath:categoryFolder isDirectory:&isDir])
        {
            NSError *error=nil;
            [[NSFileManager defaultManager]createDirectoryAtPath:categoryFolder withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        
        strCachePath=[[NSString alloc]initWithFormat:@"%@",categoryFolder];
        
    }
    return strCachePath;
}
#pragma mark - Image Utilities

-(UIImage*)GetImageFromStroage:(NSString *)strID
{
    NSString *file=[NSString stringWithFormat:@"%@/%@",strCachePath,strID];
    //NSLog(@"FILE: %@",file);
    NSFileManager *fmg=[NSFileManager defaultManager];
    if([fmg fileExistsAtPath:file])
    {
        UIImage*img =[UIImage imageWithContentsOfFile:file];
        return img;
    }
    return nil;
}
-(UIImage *)GetImageFromStroageForURL:(NSString *)strURL
{
    
    NSFileManager *fmg=[NSFileManager defaultManager];
    if([fmg fileExistsAtPath:strURL])
    {
        UIImage*img =[UIImage imageWithContentsOfFile:strURL];
        return img;
    }
    return nil;
}
-(UIImage *)GetImageFromStroageForLiveURL:(NSString *)strURL
{
    
    NSString *lpath =[strURL lastPathComponent];
    
    NSString * path =[NSString stringWithFormat:@"%@/%@",strCachePath,lpath];
    
    NSFileManager *fm=[NSFileManager defaultManager];
    if([fm fileExistsAtPath:path])
    {
        UIImage*img =[UIImage imageWithContentsOfFile:strLocalFilePath];
        return img;
    }
    
    return nil;
}

@end



@implementation SDIAsyncImageView
@synthesize shouldMask;
@synthesize shouldShowLoader;
@synthesize delegate;
@synthesize intRow;
@synthesize type;
@synthesize cell;
-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self)
    {
        
        arrDownloader=[[NSMutableArray alloc]init];
    }
    return self;
}



- (void)dealloc {
    delegate=nil;
    Destroy(strLocalFilePath);
    [self CancelAllDownload];
#ifdef WITHOUT_ARC
    [super dealloc];
#endif
}


-(void)removeFromSuperview
{
    delegate=nil;
    [self CancelAllDownload];
    isRemoved=YES;
    //XLog(@"Removed from superView ");
}
-(void)AdddGestureWithDelegate:(id<SDIAsyncImageViewDelegate>)delegate
{
    self.userInteractionEnabled = YES;
    self.delegate=delegate;
    UITapGestureRecognizer *oneTouch=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(OneTouchHandeler)];
    [oneTouch setNumberOfTouchesRequired:1];
    [oneTouch setNumberOfTapsRequired:1];
    [self addGestureRecognizer:oneTouch];
#ifdef WITHOUT_ARC
    [oneTouch release];
#endif
    
}
-(void)OneTouchHandeler
{
    if(delegate && [delegate respondsToSelector:@selector(asynchImageViewDidTapped:)])
    {
        [delegate asynchImageViewDidTapped:self];
    }
}

-(void)CancelAllDownload
{
    if(arrDownloader==nil || [arrDownloader count]==0) return;
    
    NSLog(@"Cancel Downloader count:%lu",(unsigned long)[arrDownloader count]);
    for(int i =0; i<[arrDownloader count];i++)
    {
        SDIAsyncImageDownloader *downloder =[arrDownloader objectAtIndex:i];
        downloder.delegate=nil;
        [downloder CancelDownload];
        [arrDownloader removeObjectAtIndex:i];
        i=0;
    }
}
- (void)Setimage:(UIImage*)image withTempImageURL:(NSString*)tempImage
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(image==nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.image=[UIImage imageNamed:tempImage];
                
            });
            return;
        }
        
        if(shouldMask)
        {
            
            UIImage *mask =[UIImage imageNamed:@"mask_bg"];
            UIImage *mgMasked =[self maskImage:image withMask:mask];
            mgMasked=[mgMasked ScaleImageToRect:mgMasked displaySize:self.frame.size];
            //self.image=mgMasked;
            dispatch_async(dispatch_get_main_queue(), ^{
                //
                self.image=mgMasked;
                [self setNeedsDisplay];
            });
            //[self setImage:mgMasked];
            //[self performSelectorOnMainThread:@selector(setImage:) withObject:mgMasked waitUntilDone:YES];
        }
        else
        {
            //self.contentMode=UIViewContentModeScaleAspectFit;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // image = [image ScaleImageToRect:self.frame displaySize:self.frame.size];
                
                UIImage *img =[image imageByScalingAndCroppingForSize:self.frame.size];;
                
                [self setImage:img];
                
            });
        }
    });
    
}

- (void)loadImageFromURL:(NSString*)imageURL withTempImage:(NSString*)tempImage {
    
    
    //myQueue=[del GetDownloadQueue];
    if(shouldShowLoader==YES)
    {
        [self performSelectorOnMainThread:@selector(HidProgressBar) withObject:nil waitUntilDone:YES];
    }
    
    if(imageURL!=nil && imageURL.length>0)
    {
        self.backgroundColor=[UIColor clearColor];
        NSString *lpath =[imageURL lastPathComponent];
        Destroy(strLocalFilePath);
        strLocalFilePath =[[NSString alloc] initWithFormat:@"%@/%@",[SDIAsyncImageView GetCatchPath],lpath];
        NSFileManager *fm=[NSFileManager defaultManager];
        
        
        if(![fm fileExistsAtPath:strLocalFilePath])
        {
            if(tempImage!=nil)
            {
                
                // self.contentMode=UIViewContentModeScaleAspectFill;
                // self.contentMode=UIViewContentModeCenter;
                self.image=[UIImage imageNamed:tempImage];
            }
            else
            {
                self.image=nil;
            }
            [self.superview setNeedsDisplay];
            
            
            
            if(shouldShowLoader==YES)
            {
                [self performSelectorOnMainThread:@selector(HidProgressBar) withObject:nil waitUntilDone:YES];
                HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
                HUD.mode=MBProgressHUDModeAnnularDeterminate;
                
            }
            //NSLog(@"New download :%@",imageURL);
            
            [self CancelAllDownload];
            SDIAsyncImageDownloader *downloader =[[SDIAsyncImageDownloader alloc]init];
            [downloader setDelegate:self];
            [downloader DownloadImageForURL:imageURL];
            if(arrDownloader==nil)
                arrDownloader=[NSMutableArray array];
            [arrDownloader addObject:downloader];
#ifdef WITHOUT_ARC
            [downloader release];
#endif
            
        }
        else
        {
            self.backgroundColor=[UIColor clearColor];
            // dispatch_async(myQueue, ^{
            
            if(shouldMask)
            {
                UIImage *mg=[UIImage imageWithContentsOfFile:strLocalFilePath];
                UIImage *mask =[UIImage imageNamed:@"mask_bg@2x.png"];
                UIImage *mgMasked =[self maskImage:mg withMask:mask];
                
                //mgMasked=[mgMasked ScaleImageToRect:mgMasked displaySize:self.frame.size];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image=mgMasked;
                    
                    
                    [self setNeedsDisplay];
                });
                //[self setImage:mgMasked];
                //[self performSelectorOnMainThread:@selector(setImage:) withObject:mgMasked waitUntilDone:YES];
            }
            else
            {
                
                //self.contentMode=UIViewContentModeScaleToFill;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    UIImage *mg =[self GetImageFromStroageForURL:strLocalFilePath];//strLocalFilePath
                    if(mg!=nil)
                    {
                        
                        //saravanan
                        //  self.contentMode=UIViewContentModeCenter;
                        
                        CGSize newSize=self.bounds.size;
                        newSize.height *= self.contentScaleFactor+2;
                        newSize.width *= self.contentScaleFactor+2;
                        NSLog(@"New size;%@",NSStringFromCGSize(newSize));
                        NSLog(@"O2:%@==%f",NSStringFromCGSize(self.bounds.size),self.contentScaleFactor);
                        
                     self.contentMode=UIViewContentModeScaleToFill;
                        
                        if(self.shouldRemoveResizeImage)
                        {
                            NSLog(@"IMAG IS NILL");
                           // self.contentMode=UIViewContentModeScaleAspectFill;
                        }
                        else
                        {
                            
                            mg = [mg imageByScalingAndCroppingForSize:newSize];
                            
                           // mg =[mg cropCenterAndScaleImageToSize:newSize];
                         //  self.contentMode=UIViewContentModeCenter;
                           // mg = [mg scaleWithMaxSize:newSize quality:1];
                            
                        }
                        if(isRemoved==YES){NSLog(@"PREVENTING CRASH"); return;}
                        
                        self.image=mg;
                        [self setNeedsDisplay];
                       //self.contentMode=UIViewContentModeScaleAspectFill;
                        self.backgroundColor = [UIColor redColor];

                    }
                    else
                    {
                        NSLog(@"IMAG IS NILL");
                    }
                });
                
                //self.image =[UIImage imageWithContentsOfFile:strLocalFilePath];
            }
            // });
        }
    }
    else
    {
        if(tempImage!=nil)
        {
            // NSLog(@"Temp image loaded");
            //self.contentMode=UIViewContentModeCenter;
            self.image=[UIImage imageNamed:tempImage];
        }
        //self.image=nil;
        
    }
}

-(UIImage *)image :(UIImage *)image toSize:(CGSize)newSize
{
    float width = newSize.width;
    float height = newSize.height;
    
    UIGraphicsBeginImageContext(newSize);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    float widthRatio = image.size.width / width;
    float heightRatio = image.size.height / height;
    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    width = image.size.width / divisor;
    height = image.size.height / divisor;
    
    rect.size.width  = width;
    rect.size.height = height;
    
    //indent in case of width or height difference
    float offset = (width - height) / 2;
    if (offset > 0) {
        rect.origin.y = offset;
    }
    else {
        rect.origin.x = -offset;
    }
    
    [image drawInRect: rect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return smallImage;
    
}
- (void)loadImageFromURL:(NSString*)imageURL withthumbImage:(NSString*)thumbImage {
    
    
    //myQueue=[del GetDownloadQueue];
    if(shouldShowLoader==YES)
    {
        [self performSelectorOnMainThread:@selector(HidProgressBar) withObject:nil waitUntilDone:YES];
    }
    
    if(imageURL!=nil && imageURL.length>0)
    {
        self.backgroundColor=[UIColor lightGrayColor];
        NSString *lpath =[imageURL lastPathComponent];
        Destroy(strLocalFilePath);
        strLocalFilePath =[[NSString alloc] initWithFormat:@"%@/%@",strCachePath,lpath];
        NSFileManager *fm=[NSFileManager defaultManager];
        
        if(![fm fileExistsAtPath:strLocalFilePath])
        {
            if(thumbImage!=nil)
            {
                //self.contentMode=UIViewContentModeCenter;
                NSString *lpath2 =[thumbImage lastPathComponent];
                NSString *mgURL =[NSString stringWithFormat:@"%@/%@",strCachePath,lpath2];
                self.image=[UIImage imageWithContentsOfFile:mgURL];
            }
            
            
            if(shouldShowLoader==YES)
            {
                [self performSelectorOnMainThread:@selector(HidProgressBar) withObject:nil waitUntilDone:YES];
                HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
                HUD.mode=MBProgressHUDModeAnnularDeterminate;
                
            }
            // NSLog(@"New download :%@",imageURL);
            [self CancelAllDownload];
            SDIAsyncImageDownloader *downloader =[[SDIAsyncImageDownloader alloc]init];
            [downloader setDelegate:self];
            [downloader DownloadImageForURL:imageURL];
            if(arrDownloader==nil )
                arrDownloader=[[NSMutableArray alloc]init];
            
            [arrDownloader addObject:downloader];
            //NSLog(@"Downloader count:%@",arrDownloader);
#ifdef WITHOUT_ARC
            [downloader release];
#endif
            
        }
        else
        {
            self.backgroundColor=[UIColor clearColor];
            // dispatch_async(myQueue, ^{
            
            if(shouldMask)
            {
                UIImage *mg=[UIImage imageWithContentsOfFile:strLocalFilePath];
                UIImage *mask =[UIImage imageNamed:@"mask_bg@2x.png"];
                UIImage *mgMasked =[self maskImage:mg withMask:mask];
                mgMasked=[mgMasked ScaleImageToRect:mgMasked displaySize:self.frame.size];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image=mgMasked;
                    [self setNeedsDisplay];
                });
                //[self setImage:mgMasked];
                //[self performSelectorOnMainThread:@selector(setImage:) withObject:mgMasked waitUntilDone:YES];
            }
            else
            {
               
               //  self.contentMode=UIViewContentModeScaleToFill;
                UIImage *mg =[self GetImageFromStroageForURL:strLocalFilePath];
                self.image=mg;
                //self.image =[UIImage imageWithContentsOfFile:strLocalFilePath];
            }
            // });
        }
    }
    else
    {
        if(thumbImage!=nil)
        {
            NSString *lpath2 =[thumbImage lastPathComponent];
            NSString *mgURL =[NSString stringWithFormat:@"%@/%@",strCachePath,lpath2];
            self.image=[UIImage imageWithContentsOfFile:mgURL];
        }
    }
}
-(void)RemoveHude
{
    
}
-(void) asyncConnection :(NSURLConnection *) connection
      didReceiveResponse:(NSURLResponse *) response
{
    if(shouldShowLoader==YES)
    {
        expectedLength = [response expectedContentLength];
        currentLength = 0;
        
        HUD.mode = MBProgressHUDModeDeterminate;
    }
    
    // NSLog(@"download response");
}
//the URL connection calls this repeatedly as data arrives
- (void)asyncConnection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    
    currentLength +=incrementalData.length;
    //NSLog(@"download len:%d",incrementalData.length);
    if(shouldShowLoader==YES && HUD!=nil)
    {
        HUD.progress = currentLength / (float)expectedLength;
    }
    
    
    
}
-(void)asyncImageDownloader:(SDIAsyncImageDownloader *)asimage didcompletedWithLocalURL:(NSString *)strURL
{
    
    //Destroy(connection)
    
    //NSFileManager *defMngr=[NSFileManager defaultManager];
    
    if([strLocalFilePath isEqualToString:strURL])
    {
        [self performSelectorOnMainThread:@selector(HidProgressBar) withObject:nil waitUntilDone:YES];
        //MQ_
        if(delegate && [delegate respondsToSelector:@selector(asynchImageView:didCachedImage:)])
        {
            [delegate asynchImageView:self didCachedImage:strURL];
        }
        //NSLog(@"Download URL:%@",strURL);
        //self.autoresizingMask = ( UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight );
        if(isRemoved==YES){NSLog(@"PREVENTING CRASH"); return;}
        [self UpdateImage:strURL];
        
        // _MQ
    }
    else
    {
        //NSLog(@"%@=>%@",strLocalFilePath,strURL);
        //NSLog(@"Not Found");
    }
    
    
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    //so self data now has the complete image
    
    //Destroy(connection)
    MQ_
    self.autoresizingMask = ( UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight );
    [self UpdateImage:strLocalFilePath];
    [self setNeedsLayout];
    _MQ
    
    //NSLog(@"end");
    
    
}

-(void)RemoveHud
{
    
    if(shouldShowLoader==YES)
    {
        shouldShowLoader=NO;
        NSLog(@"Hud Removed");
        [MBProgressHUD hideHUDForView:self animated:YES];
        HUD=nil;
        
        
    }
    
}
-(void)HidProgressBar
{
    if(shouldShowLoader==YES)
    {
        
        //NSLog(@"Hud Removed");
        [MBProgressHUD hideHUDForView:self animated:YES];
        HUD=nil;
        
        
    }
}
-(void)asyncconnection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(HidProgressBar) withObject:nil waitUntilDone:NO];
}

-(void)UpdateImage:(NSString*)filename
{
    //self.contentMode=UIViewContentModeScaleToFill;
    // MQ_
    if(isRemoved==YES){NSLog(@"PREVENTING CRASH"); return;}
    self.shouldRemoveResizeImage = false;
    self.backgroundColor=[UIColor clearColor];
    if(shouldMask)
    {
        UIImage *mg=[UIImage imageWithContentsOfFile:filename];
        UIImage *mask =[UIImage imageNamed:@"mask_bg"];
        UIImage *mgMasked =[self maskImage:mg withMask:mask];
        [self performSelectorOnMainThread:@selector(setImage:) withObject:mgMasked waitUntilDone:YES];
    }
    else
    {
        UIImage *mg =[UIImage imageWithContentsOfFile:filename];
        if(self.shouldRemoveResizeImage)
        {
            self.contentMode=UIViewContentModeScaleAspectFill;
        }
        else
        {
            CGSize mysize = self.bounds.size;
            mysize.height *= self.contentScaleFactor+2;
            mysize.width *= self.contentScaleFactor+2;
           // NSLog(@"New size :%@",NSStringFromCGSize(mysize));
            self.contentMode=UIViewContentModeScaleToFill;
            
            mg = [mg imageByScalingAndCroppingForSize:mysize];
            
        }
         //self.contentMode=UIViewContentModeScaleToFill;
        [self performSelectorOnMainThread:@selector(setImage:) withObject:mg waitUntilDone:YES];
    }
    //_MQ
    //XLog(@"image updated");
}
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    
    // returns new image with mask applied
    return maskedImage;
}

/*
 //just in case you want to get the image directly, here it is in subviews
 - (UIImage*) image {
	
	return [self image];
 }
 
 */


@end
