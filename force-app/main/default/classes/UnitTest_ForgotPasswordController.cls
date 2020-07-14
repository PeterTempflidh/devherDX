@isTest
public class UnitTest_ForgotPasswordController {
    static testMethod void ForgotPassword() {
        ForgotPasswordController fpc = new ForgotPasswordController();
        fpc.username = 'test';
        fpc.forgotPassword();
    }
}