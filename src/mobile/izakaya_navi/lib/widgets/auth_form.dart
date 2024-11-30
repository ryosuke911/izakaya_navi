import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(String email, String password, bool isLogin) onSubmit;

  const AuthForm({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  String _email = '';
  String _password = '';

  void _trySubmit() {
    final isValid = _formKey.currentState?.validate();

    if (isValid != null && isValid) {
      _formKey.currentState?.save();
      widget.onSubmit(
        _email.trim(),
        _password.trim(),
        _isLogin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const ValueKey('email'),
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return '有効なメールアドレスを入力してください';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'メールアドレス'),
                  onSaved: (value) {
                    _email = value ?? '';
                  },
                ),
                TextFormField(
                  key: const ValueKey('password'),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'パスワードは6文字以上で入力してください';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'パスワード'),
                  obscureText: true,
                  onSaved: (value) {
                    _password = value ?? '';
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _trySubmit,
                  child: Text(_isLogin ? 'ログイン' : '新規登録'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(_isLogin ? '新規アカウントを作成' : 'ログインに戻る'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}