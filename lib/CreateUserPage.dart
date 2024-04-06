import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateUserPage extends StatefulWidget {
  @override
  State createState() {
    return _CreateUserState();
  }
}

class _CreateUserState extends State<CreateUserPage> {
  late String email, password;
  final _formKey = GlobalKey<FormState>();
  String error = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tutorial Firebase"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Crear Usuario", style: TextStyle(color: Colors.black, fontSize: 24),),
          ),
          Offstage(
            offstage: error == '',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(error, style: TextStyle(color: Colors.red, fontSize: 16),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: formulario(),
          ),
          butonCrearUsuario(),
        ],
      ),
    );
  }

  Widget formulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmail(),
          const Padding(padding: EdgeInsets.only(top: 12)),
          buildPassword(),
        ],
      ),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Correo",
        border: OutlineInputBorder(
          borderRadius: new BorderRadius.circular(8),
          borderSide: new BorderSide(color: Colors.black),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String? value) {
        email = value!;
      },
      validator: (String? value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget buildPassword() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Contraseña",
        border: OutlineInputBorder(
          borderRadius: new BorderRadius.circular(8),
          borderSide: new BorderSide(color: Colors.black),
        ),
        hintText: "Mínimo 8 caracteres, 1 mayúscula, 1 minúscula, 1 número",
      ),
      obscureText: true,
      validator: (String? value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        if (!isValidPassword(value)) {
          return "La contraseña no cumple con los requisitos de seguridad";
        }
        return null;
      },
      onSaved: (String? value) {
        password = value!;
      },
    );
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$");
    return passwordRegex.hasMatch(password);
  }

  Widget butonCrearUsuario() {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            UserCredential? credenciales = await crear(email, password);
            if (credenciales != null) {
              if (credenciales.user != null) {
                await credenciales.user!.sendEmailVerification();
                Navigator.of(context).pop();
              }
            }
          }
        },
        child: Text("Registrarse"),
      ),
    );
  }

  Future<UserCredential?> crear(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          error = "El correo electrónico ya se encuentra en uso.";
        });
      } else if (e.code == 'weak-password') {
        setState(() {
          error = "La contraseña es demasiado débil. Por favor, elija una contraseña más segura.";
        });
      } else {
        // Handle other errors (e.g., network issues)
        print("Error al crear usuario: ${e.code}");
      }
      return null;
    }
  }
}