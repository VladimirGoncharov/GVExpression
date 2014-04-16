GVExpression
============

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    NSString *text      = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    switch (textFieldType)
    {
        case AddressTextFieldTypeDecimal:
        {
            GVNumbersRegularExpression *expression = [GVNumbersRegularExpression new];
            BOOL result  = [expression validateText:text];
            if (result)
            {
                BLOCK_SAFE_RUN(self.didChangeText, text);
            }
            return result;
        }; break;
            
        case AddressTextFieldTypeString:
        {
            GVStringsRegularExpression *expression = [GVStringsRegularExpression new];
            BOOL result  = [expression validateText:text];
            if (result)
            {
                BLOCK_SAFE_RUN(self.didChangeText, text);
            }
            return result;
        }; break;
            
        case OPAddressTextCellRightTextFieldTypePhoneNumber:
        {
            NSCharacterSet *set                     = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            NSArray *numbersArray                   = [textField.text componentsSeparatedByCharactersInSet:set];
            text                                    = [numbersArray componentsJoinedByString:@""];
            text                                    = [text stringByAppendingString:string];
            if (text.length > 1 && [string isEqualToString:@""])
            {
                text                                = [text substringToIndex:text.length - 1];
            }
            
            text                          = [phoneFormatter() formattedText:text];
            
            textField.text                = text;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification
                                                                object:textField];
            BLOCK_SAFE_RUN(self.didChangeText, text);
            
            return NO;
        }; break;
            
        default:
            break;
    }
    
    BLOCK_SAFE_RUN(self.didChangeText, text);
    
    return YES;
}
