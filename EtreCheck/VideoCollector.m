/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "VideoCollector.h"
#import "NSMutableAttributedString+Etresoft.h"
#import "Utilities.h"
#import "NSArray+Etresoft.h"
#import "Model.h"
#import "TTTLocalizedPluralString.h"
#import "SubProcess.h"
#import "XMLBuilder.h"

@implementation VideoCollector

// Constructor.
- (id) init
  {
  self = [super initWithName: @"video"];
  
  if(self)
    {
    return self;
    }
    
  return nil;
  }

// Collect video information.
- (void) performCollection
  {
  [self
    updateStatus: NSLocalizedString(@"Checking video information", NULL)];

  NSArray * args =
    @[
      @"-xml",
      @"SPDisplaysDataType"
    ];
  
  SubProcess * subProcess = [[SubProcess alloc] init];
  
  if([subProcess execute: @"/usr/sbin/system_profiler" arguments: args])
    {
    NSArray * plist =
      [NSArray readPropertyListData: subProcess.standardOutput];
  
    if(plist && [plist count])
      {
      NSArray * infos = [[plist objectAtIndex: 0] objectForKey: @"_items"];
        
      if([infos count])
        [self printVideoInformation: infos];
      }
    }
    
  [subProcess release];
    
  dispatch_semaphore_signal(self.complete);
  }

// Print video information.
- (void) printVideoInformation: (NSArray *) infos
  {
  [self.result appendAttributedString: [self buildTitle]];
  
  for(NSDictionary * info in infos)
    {
    [self.XML startElement: @"videocard"];
    
    NSString * name = [info objectForKey: @"sppci_model"];
    
    if(![name length])
      name = NSLocalizedString(@"Unknown", NULL);
      
    [self.XML addElement: @"name" value: name];
    
    NSString * vramAmount = [info objectForKey: @"spdisplays_vram"];

    NSString * vram = @"";
    
    if(vramAmount)
      {
      [self.XML addElement: @"VRAM" value: vramAmount];
      
      vram =
        [NSString
          stringWithFormat:
            NSLocalizedString(@"VRAM: %@", NULL), vramAmount];
      }
      
    [self.result
      appendString:
        [NSString
          stringWithFormat:
            @"    %@%@%@\n",
            name ? name : @"",
            [vram length] ? @" - " : @"",
            vram]];
      
    NSArray * displays = [info objectForKey: @"spdisplays_ndrvs"];
  
    for(NSDictionary * display in displays)
      [self printDisplayInfo: display];
      
    [self.XML endElement: @"videocard"];
    }
    
  NSNumber * errors = [[Model model] gpuErrors];
    
  int errorCount = [errors intValue];
  
  if(errorCount)
    [self.result
      appendString:
        [NSString
          stringWithFormat:
            NSLocalizedString(@"GPU failure! - %@\n", NULL),
            TTTLocalizedPluralString(errorCount, @"error", NULL)]
      attributes:
        @{
          NSForegroundColorAttributeName : [[Utilities shared] red],
          NSFontAttributeName : [[Utilities shared] boldFont]
        }];
    
  [self.result appendCR];
  }

// Print information about a display.
- (void) printDisplayInfo: (NSDictionary *) display
  {
  [self.XML startElement: @"display"];
  
  NSString * name = [display objectForKey: @"_name"];
  
  if([name isEqualToString: @"spdisplays_display"])
    name = NSLocalizedString(@"Display", NULL);
    
  [self.XML addElement: @"name" value: name];
  
  NSString * resolution = [display objectForKey: @"spdisplays_resolution"];

  if([resolution hasPrefix: @"spdisplays_"])
    {
    NSString * pixels = [display objectForKey: @"_spdisplays_pixels"];
    
    if(pixels)
      resolution = pixels;
    }
    
  if(resolution)
    [self.XML addElement: @"resolution" value: resolution];
    
  if(name || resolution)
    [self.result
      appendString:
        [NSString
          stringWithFormat:
            @"        %@ %@\n",
            name ? name : @"Unknown",
            resolution ? resolution : @""]];
  
  [self.XML endElement: @"display"];
  }

@end
