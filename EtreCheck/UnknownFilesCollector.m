/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "UnknownFilesCollector.h"
#import "Model.h"
#import "DiagnosticEvent.h"
#import "NSMutableAttributedString+Etresoft.h"
#import "Utilities.h"
#import "TTTLocalizedPluralString.h"
#import "LaunchdCollector.h"
#import "XMLBuilder.h"

#define kWhitelistKey @"whitelist"
#define kWhitelistPrefixKey @"whitelist_prefix"

// Collect information about unknown files.
@implementation UnknownFilesCollector

// Constructor.
- (id) init
  {
  self = [super initWithName: @"unknownfiles"];
  
  if(self)
    {
    return self;
    }
    
  return nil;
  }

// Perform the collection.
- (void) performCollection
  {
  [self
    updateStatus: NSLocalizedString(@"Checking for unknown files", NULL)];

  [self printUnknownFiles];
  }

// Print any unknown files.
- (void) printUnknownFiles
  {
  NSDictionary * unknownLaunchdFiles = [[Model model] unknownLaunchdFiles];
  NSArray * unknownFiles = [[Model model] unknownFiles];
  
  NSUInteger unknownFileCount =
    [unknownLaunchdFiles count] + [unknownFiles count];
  
  if(unknownFileCount > 0)
    {
    [self.result appendAttributedString: [self buildTitle]];
    
    NSArray * sortedUnknownLaunchdFiles =
      [[unknownLaunchdFiles allKeys]
        sortedArrayUsingSelector: @selector(compare:)];
      
    [sortedUnknownLaunchdFiles
      enumerateObjectsUsingBlock:
        ^(id obj, NSUInteger idx, BOOL * stop)
          {
          [self.result
            appendString:
              [NSString
                stringWithFormat: @"    %@", [Utilities cleanPath: obj]]];

          NSDictionary * info = [unknownLaunchdFiles objectForKey: obj];
          
          [self.result
            appendString:
              [NSString
                stringWithFormat:
                  @"\n        %@\n",
                  [Utilities
                    formatExecutable: [info objectForKey: kCommand]]]];
            
          [self.XML startElement: @"unknownfile"];

          [self.XML
            addElement: @"path"
            value: [Utilities prettyPath: obj]];
          
          [self.XML
            addElement: @"command"
            value:
              [Utilities formatExecutable: [info objectForKey: kCommand]]];

          [self.XML endElement: @"unknownfile"];
          }];
      
    NSArray * sortedUnknownFiles =
      [unknownFiles sortedArrayUsingSelector: @selector(compare:)];
      
    [sortedUnknownFiles
      enumerateObjectsUsingBlock:
        ^(id obj, NSUInteger idx, BOOL * stop)
          {
          [self.result
            appendString:
              [NSString
                stringWithFormat: @"    %@\n", [Utilities cleanPath: obj]]];
          }];

    NSString * message =
      TTTLocalizedPluralString(unknownFileCount, @"unknown file", NULL);

    [self.result appendString: @"    "];
    
    [self.result
      appendString: message
      attributes:
        @{
          NSForegroundColorAttributeName : [[Utilities shared] red],
          NSFontAttributeName : [[Utilities shared] boldFont]
        }];
    
    NSAttributedString * checkLink =
      [self generateCheckFilesLink: @"files"];

    if(checkLink)
      {
      [self.result appendAttributedString: checkLink];
      [self.result appendString: @"\n"];
      }
    
    [self.result appendCR];
    }
  }

@end
