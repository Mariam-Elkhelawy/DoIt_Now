import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/core/cache/shared_prefrences.dart';
import 'package:todo_app/features/data/models/category_model.dart';
import 'package:todo_app/features/data/models/task_model.dart';
import 'package:todo_app/features/data/models/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FirebaseFunctions {
  static CollectionReference<TaskModel> getTaskCollection() {
    return FirebaseFirestore.instance
        .collection('Tasks')
        .withConverter<TaskModel>(
      fromFirestore: (snapshot, _) {
        return TaskModel.fromJson(snapshot.data()!);
      },
      toFirestore: (value, _) {
        return value.toJson();
      },
    );
  }

  static CollectionReference<CategoryModel> getCategoryCollection() {
    return FirebaseFirestore.instance
        .collection('Categories')
        .withConverter<CategoryModel>(
      fromFirestore: (snapshot, _) {
        return CategoryModel.fromJson(snapshot.data()!);
      },
      toFirestore: (value, _) {
        return value.toJson();
      },
    );
  }

  static Future<List<CategoryModel>> getCategories() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Categories')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static CollectionReference<UserModel> getUserCollection() {
    return FirebaseFirestore.instance
        .collection('Users')
        .withConverter<UserModel>(
      fromFirestore: (snapshot, _) {
        return UserModel.fromJson(snapshot.data()!);
      },
      toFirestore: (value, _) {
        return value.toJson();
      },
    );
  }

  static Future<void> addTask(TaskModel taskModel) {
    var collection = getTaskCollection();
    var docRef = collection.doc();
    taskModel.id = docRef.id;
    return docRef.set(taskModel);
  }

  static Future<void> addUser(UserModel userModel) {
    var collection = getUserCollection();
    var docRef = collection.doc(userModel.id);
    return docRef.set(userModel);
  }

  static Future<void> addCategory(CategoryModel categoryModel) {
    var collection = getCategoryCollection();
    var docRef = collection.doc();
    categoryModel.id = docRef.id;
    return docRef.set(categoryModel);
  }

  static Stream<QuerySnapshot<TaskModel>> getTask(DateTime date) {
    return getTaskCollection()
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('date',
            isEqualTo: DateUtils.dateOnly(date).millisecondsSinceEpoch)
        .snapshots();
  }

  static Stream<QuerySnapshot<TaskModel>> getImportantTasks() {
    return getTaskCollection()
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('isImportant', isEqualTo: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<CategoryModel>> getCategory() {
    return getCategoryCollection()
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  static Future<void> deleteTask(String id) {
    return getTaskCollection().doc(id).delete();
  }

  static Future<void> deleteCategory(String id) {
    return getCategoryCollection().doc(id).delete();
  }

  static Future<void> updateTask(TaskModel model) {
    return getTaskCollection().doc(model.id).update(model.toJson());
  }

  static Future<void> updateCategory(CategoryModel model) {
    return getTaskCollection().doc(model.id).update(model.toJson());
  }

  static Future<void> register(
      {required String email,
      required String password,
      required String userName,
      required Function onSuccess,
      required Function onError,
      required BuildContext context}) async {
    var local = AppLocalizations.of(context)!;

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      credential.user!.sendEmailVerification();
      UserModel userModel = UserModel(
          id: credential.user?.uid ?? '', email: email, userName: userName);
      await addUser(userModel);
      onSuccess();
      CacheHelper.saveData('name', userName);
      CacheHelper.saveData('email', email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        onError(local.emailInUse);
      }
      onError(local.wrongMessage);
    } catch (e) {
      onError(local.wrongMessage);
    }
  }

  static Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<void> login(
      {required String email,
      required String password,
      required Function onSuccess,
      required Function onError,
      required BuildContext context}) async {
    var local = AppLocalizations.of(context)!;

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (credential.user!.emailVerified) {
        onSuccess();
      } else {
        onError(local.emailVerification);
      }
    } on FirebaseAuthException {
      onError(local.wrongLogin);
    }
  }

  static bool isLoggedBefore() {
    return FirebaseAuth.instance.currentUser != null;
  }
}
