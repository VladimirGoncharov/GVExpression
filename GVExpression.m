#import "GVExpression.h"

static inline NSString *decimalSeparatorWithCurrentLocale()
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    return [formatter decimalSeparator];
}



#pragma mark - class GVNumbersRegularExpression

@implementation GVNumbersRegularExpression

- (id)init
{
    self            = [super init];
    if (self)
    {
        self.firstSymbolIsZeroAvailable     = YES;
        self.numberOfDecimalFractions       = 0;
        self.decimalSeparator               = decimalSeparatorWithCurrentLocale();
    }
    return self;
}

#pragma mark - <GVExpression>

- (BOOL)validateText:(NSString *)text
{
    NSString *expression       = @"([0-9]+)?";
    
    if (!self.firstSymbolIsZeroAvailable)
    {
        expression  = [NSString stringWithFormat:@"^([1-9]{1})%@", expression];
    }
    else
    {
        expression  = [NSString stringWithFormat:@"^%@", expression];
    }
    
    if (self.numberOfDecimalFractions != 0)
    {
        expression  = [NSString stringWithFormat:@"%@(\\%@([0-9]{1,%lu})?)?$", expression, self.decimalSeparator, (unsigned long)self.numberOfDecimalFractions];
    }
    else
    {
        expression  = [NSString stringWithFormat:@"%@$", expression];
    }
    
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:text
                                                        options:0
                                                          range:NSMakeRange(0, [text length])];
    
    return (numberOfMatches != 0);
}

@end



#pragma mark - class GVStringsRegularExpression

@implementation GVStringsRegularExpression

- (id)init
{
    self            = [super init];
    if (self)
    {
        self.ignoreSymbols              = [NSCharacterSet punctuationCharacterSet];
    }
    return self;
}

#pragma mark - <OPExpression>

- (BOOL)validateText:(NSString *)text
{
    NSCharacterSet *setDecimal         = [NSCharacterSet decimalDigitCharacterSet];
    
    return (([text rangeOfCharacterFromSet:self.ignoreSymbols].location == NSNotFound) && ([text rangeOfCharacterFromSet:setDecimal].location == NSNotFound));
}

@end



#pragma mark - class GVEmailRegularExpression

@implementation GVEmailRegularExpression

- (BOOL)validateText:(NSString *)text
{
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:text];
}

@end






#pragma mark - class GVPhoneFormatter

@implementation GVPhoneFormatter

- (id)init
{
    self            = [super init];
    if (self)
    {
        self.format              = @"+%@(%@%@%@)-%@%@%@-%@%@-%@%@";
        self.maskSymbol          = nil;
        self.displayMaskSymbols  = NO;
    }
    return self;
}

#pragma mark - private

- (NSString *)_trimAllButANumber:(NSString *)text
{
    if (text.length == 0)
    {
        return text;
    }
    
    NSCharacterSet *set                     = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray *numbersArray                   = [text componentsSeparatedByCharactersInSet:set];
    return [numbersArray componentsJoinedByString:@""];
}

- (NSUInteger)_countNumbersToFormat
{
    return [[self.format componentsSeparatedByString:@"%@"] count] - 1;
}

#pragma mark - <GVExpression>

- (BOOL)validateText:(NSString *)text
{
    text                                = [self _trimAllButANumber:text];
    
    NSUInteger countAddingNumbers       = [self _trimAllButANumber:self.format].length;
    text                                = [text stringByReplacingCharactersInRange:NSMakeRange(0, countAddingNumbers)
                                                                        withString:@""];
    return (text.length == [self _countNumbersToFormat]);
}

#pragma mark - <GVFormatter>

- (NSString *)formattedText:(NSString *)text
{
    text                                = [self _trimAllButANumber:text];
    
    NSUInteger countAddingNumbers       = [self _trimAllButANumber:self.format].length;
    text                                = [text stringByReplacingCharactersInRange:NSMakeRange(0, countAddingNumbers)
                                                                        withString:@""];
    
    if (text.length > [self _countNumbersToFormat])
    {
        text                                = [text substringToIndex:[self _countNumbersToFormat] + 1];
    }
    
    NSUInteger numberOfFormat = [self _countNumbersToFormat];
    NSString *resultText      = self.format;
    
    for (NSUInteger i = 0; i < text.length; i++)
    {
        if (!numberOfFormat)
            break;
        
        NSString *symbol                    = [text substringWithRange:NSMakeRange(i, 1)];
        NSRange  rangeReplacingToFormat     = [resultText rangeOfString:@"%@"];
        
        resultText                          = [resultText stringByReplacingCharactersInRange:rangeReplacingToFormat
                                                                                  withString:symbol];
        
        numberOfFormat--;
    }
    
    if (self.displayMaskSymbols)
    {
        for (NSUInteger i = 0; i < numberOfFormat; i++)
        {
            NSRange  rangeReplacingToFormat     = [resultText rangeOfString:@"%@"];
            
            resultText                          = [resultText stringByReplacingCharactersInRange:rangeReplacingToFormat
                                                                                      withString:self.maskSymbol];
        }
    }
    else
    {
        if (numberOfFormat)
        {
            NSRange  rangeDelete                = [resultText rangeOfString:@"%@"];
            rangeDelete                         = NSMakeRange(rangeDelete.location, [resultText length] - rangeDelete.location);
            
            resultText                          = [resultText stringByReplacingCharactersInRange:rangeDelete withString:@""];
        }
    }
    
    return resultText;
}

@end
