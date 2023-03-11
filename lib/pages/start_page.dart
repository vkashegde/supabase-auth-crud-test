import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _signInLoading = false;
  bool _signUpLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _googleSignInLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    supabase.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //signup functionality

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.network(
                      'https://cf.appdrag.com/dashboard-openvm-clo-b2d42c/uploads/supabase-TAiY.png',
                      height: 150,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    //email
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field is required ";
                        }

                        return null;
                      },
                      controller: _emailController,
                      decoration: const InputDecoration(label: Text('Email')),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    //password
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field is required ";
                        }

                        return null;
                      },
                      controller: _passwordController,
                      decoration:
                          const InputDecoration(label: Text('Password')),
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    _signInLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              final isvalid = _formKey.currentState?.validate();
                              if (isvalid != true) {
                                return;
                              }

                              setState(() {
                                _signInLoading = true;
                              });

                              try {
                                await supabase.auth.signInWithPassword(
                                    email: _emailController.text,
                                    password: _passwordController.text);
                                // ScaffoldMessenger.of(context)
                                //     .showSnackBar(SnackBar(
                                //   content:
                                //       Text('Success ! Confirmation email sent'),
                                //   backgroundColor: Color(0xff12E2A3),
                                // ));

                                setState(() {
                                  _signInLoading = false;
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content:
                                      Text(' Sign In Failed : ${e.toString()}'),
                                  backgroundColor:
                                      Color.fromARGB(255, 243, 17, 6),
                                ));
                                setState(() {
                                  _signInLoading = false;
                                });
                              }
                            },
                            child: const Text('Sign In'),
                          ),
                    const Divider(),
                    _signUpLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : OutlinedButton(
                            onPressed: () async {
                              final isvalid = _formKey.currentState?.validate();
                              if (isvalid != true) {
                                return;
                              }

                              setState(() {
                                _signUpLoading = true;
                              });

                              try {
                                await supabase.auth.signUp(
                                    email: _emailController.text,
                                    password: _passwordController.text);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content:
                                      Text('Success ! Confirmation email sent'),
                                  backgroundColor: Color(0xff12E2A3),
                                ));

                                setState(() {
                                  _signUpLoading = false;
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('${e.toString()}'),
                                  backgroundColor:
                                      Color.fromARGB(255, 243, 17, 6),
                                ));
                                setState(() {
                                  _signUpLoading = false;
                                });
                              }
                            },
                            child: const Text('Sign Up')),

                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    _googleSignInLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : OutlinedButton.icon(
                            onPressed: () async {
                              setState(() {
                                _googleSignInLoading = true;
                              });

                              try {
                                await supabase.auth.signInWithOAuth(
                                    Provider.google,
                                    redirectTo: kIsWeb
                                        ? null
                                        : 'io.supabase.myflutterapp://login-callback');
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('${e.toString()}'),
                                  backgroundColor:
                                      Color.fromARGB(255, 243, 17, 6),
                                ));
                                setState(() {
                                  _googleSignInLoading = false;
                                });
                              }
                            },
                            icon: Image.network(
                              'https://w7.pngwing.com/pngs/989/129/png-transparent-google-logo-google-search-meng-meng-company-text-logo-thumbnail.png',
                              height: 26,
                            ),
                            label: Text('Continue with google'))
                  ],
                ),
              ))),
    );
  }
}
