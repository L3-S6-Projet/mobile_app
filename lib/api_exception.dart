import 'dart:convert';

import 'package:openapi/api.dart';

const UNKNOWN_ERROR = "Erreur inconnue.";
const INTERNAL_ERROR = "Erreur interne.";

const KEYS = <String, String>{
  "InvalidCredentials": "Identifiants invalides.",
  "InsufficientAuthorization":
      "Vous n'avez pas les droits requis pour cette action.",
  "MalformedData": INTERNAL_ERROR,
  "InvalidOldPassword": "L'ancien mot de passe n'est pas valide.",
  "PasswordTooSimple": "Le mot de passe fourni est trop simple.",
  "InvalidEmail": "L'email fourni est invalide.",
  "InvalidPhoneNumber": "Le numéro de téléphone fourni est invalide.",
  "InvalidRank": INTERNAL_ERROR,
  "InvalidID": INTERNAL_ERROR,
  "InvalidCapacity": "La capacité fournie est invalide.",
  "TeacherInCharge": "Le professeur choisi est responsable d'une matière.",
  "ClassroomUsed": "La salle choisie est occupée.",
  "InvalidLevel": INTERNAL_ERROR,
  "ClassUsed": "La classe choisie est occupée.",
  "StudentInClass": "La classe choisie a toujours (au moins) un étudiant.",
  "SubjectUsed": "Le sujet est utilisé dans un occupation.",
  "TeacherNotInCharge": "Le professeur choisi n'est pas responsable.",
  "LastTeacherInSubject": "Le professeur choisi est le dernier de la matière.",
  "LastGroupInSubject": "Le groupe choisi est le dernier de la matière.",
  "ClassroomAlreadyOccupied": "La salle est déjà occupée.",
  "ClassOrGroupAlreadyOccupied": "La classe ou le groupe est déjà occupé.",
  "InvalidOccupancyType": INTERNAL_ERROR,
  "EndBeforeStart": INTERNAL_ERROR,
  "TeacherDoesNotTeach": "Le professeur choisi n'enseigne pas cette matière.",
  "IllegalOccupancyType": INTERNAL_ERROR,
  "TeacherAlreadyOccupied": "Le professeur choisi est déjà occupé.",
  "Unknown": UNKNOWN_ERROR,
};

String getErrorMessage(String code) {
  print('?? : ' + code);
  return KEYS[code] ?? UNKNOWN_ERROR;
}

String getErrorMessageFromException(Exception e) {
  if (e is ApiException) {
    return getErrorMessage(jsonDecode(e.message)['code']);
  }

  return UNKNOWN_ERROR;
}
