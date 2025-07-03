import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_page.dart';
import '../../../utils/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // Firebase 不需要初始化預設用戶
    // AuthService.initDefaultUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // 處理登入
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // 確保無論結果如何都先停止載入
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (result.success) {
        // 登入成功，返回上一個頁面
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          // 顯示成功訊息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations?.loginSuccess ?? '登入成功')),
          );
          
          // 延遲一下再返回，讓使用者看到成功提示
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              // 直接返回前一個頁面，而不是替換當前頁面
              Navigator.pop(context, true);
            }
          });
        }
      } else {
        // 登入失敗
        if (mounted) {
          setState(() {
            final localizations = AppLocalizations.of(context);
            _errorMessage = result.errorMessage ?? (localizations?.accountOrPasswordError ?? '帳號或密碼錯誤');
          });
        }
      }
    } catch (e) {
      // 處理任何其他非預期錯誤
      print('登入時發生未預期錯誤: $e');
      
      if (mounted) {
        setState(() {
          final localizations = AppLocalizations.of(context);
          _errorMessage = localizations?.loginErrorMessage ?? '登入時發生錯誤，請稍後再試';
          _isLoading = false;
        });
      }
    }
  }

  // 處理忘記密碼
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      final localizations = AppLocalizations.of(context);
      // 如果郵件欄位為空，顯示錯誤提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.pleaseEnterEmailFirst ?? '請先輸入您的電子郵件')),
      );
      return;
    }

    // 顯示載入指示器
    setState(() {
      _isLoading = true;
    });

    try {
      // 調用密碼重設功能
      final success = await AuthService.resetPassword(email);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (success) {
          final localizations = AppLocalizations.of(context);
          // 顯示成功訊息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations?.passwordResetEmailSent(email) ?? '密碼重設郵件已發送到 $email')),
          );
        } else {
          final localizations = AppLocalizations.of(context);
          // 顯示錯誤訊息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations?.passwordResetFailedMessage ?? '發送密碼重設郵件失敗，請確認郵箱是否正確')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.passwordResetErrorMessage ?? '發送密碼重設郵件時發生錯誤')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.loginPageTitle ?? '登入'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 標題
                Text(
                  localizations?.welcomeBack ?? '歡迎回來',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations?.loginToContinue ?? '登入以繼續使用所有功能',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // 錯誤訊息
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 16),

                // 電子郵件欄位
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: localizations?.email ?? '電子郵件',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations?.pleaseEnterEmail ?? '請輸入電子郵件';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 密碼欄位
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: localizations?.password ?? '密碼',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations?.pleaseEnterPassword ?? '請輸入密碼';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 忘記密碼按鈕
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _handleForgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                    child: Text(localizations?.forgotPassword ?? '忘記密碼？'),
                  ),
                ),
                const SizedBox(height: 8),

                // 登入按鈕
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          localizations?.loginButtonText ?? '登入',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),

                // 忘記密碼按鈕 (重複的，應該移除一個)
                /*
                TextButton(
                  onPressed: _isLoading ? null : _handleForgotPassword,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue,
                          ),
                        )
                      : Text(
                          localizations?.forgotPassword ?? '忘記密碼？',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                ),
                */

                // 註冊連結
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(localizations?.dontHaveAccount ?? '還沒有帳號？'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(localizations?.registerNow ?? '立即註冊'),
                    ),
                  ],
                ),

                // 遊客登入
                TextButton(
                  onPressed: () {
                    // 直接返回前一個頁面
                    Navigator.pop(context, false);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  child: Text(localizations?.continueAsGuest ?? '以遊客身份繼續'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
