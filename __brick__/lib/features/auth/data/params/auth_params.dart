/// Body of the sign-in request.
///
/// Shaped for an email + password backend. For a platform provider (Google,
/// Apple…) replace the fields with the provider's token — the server verifies
/// it and mints its own JWT pair.
class SignInParams {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email,
    'password': password,
  };
}
