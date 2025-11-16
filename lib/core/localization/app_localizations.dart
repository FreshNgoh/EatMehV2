import 'dart:convert';
import 'package:eatmehv2/presentation/screens/user/subRecords/diet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString(
      'assets/languages/${locale.languageCode}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
// exercise record
  String get exerciseNoData => translate('exerciseNoData');
  String get exerciseCal => translate('exerciseCal');
  String get exerciseTotal => translate('exerciseTotal');
  String get exerciseMins => translate('exerciseMins');
  String get exerciseHistory => translate('exerciseHistory');
  String get exerciseAdd => translate('exerciseAdd');
  String get exerciseType => translate('exerciseType');
  String get exerciseSelectType => translate('exerciseSelectType');
  String get exerciseStartTime => translate('exerciseStartTime');
  String get exerciseSelectStart => translate('exerciseSelectStart');
  String get exerciseEndTime => translate('exerciseEndTime');
  String get exerciseSelectEnd => translate('exerciseSelectEnd');
  String get exerciseDuration => translate('exerciseDuration');
  String get exerciseCaloriesBurned => translate('exerciseCaloriesBurned');
  String get exerciseErrorFillFields => translate('exerciseErrorFillFields');
  String get exerciseSaveSuccess => translate('exerciseSaveSuccess');
  String get exerciseSaveError => translate('exerciseSaveError');
  String get exerciseSaving => translate('exerciseSaving');
  String get Running => translate('Running');
  String get Walking => translate('Walking');
  String get Cycling => translate('Cycling');
  String get Yoga => translate('Yoga');
  String get Swimming => translate('Swimming');
  String get Gym => translate('Gym');

  // trainer form
  String get trainerFormTitle => translate('trainerFormTitle');
  String get trainerFormNameLabel => translate('trainerFormNameLabel');
  String get trainerFormNameHint => translate('trainerFormNameHint');
  String get trainerFormErrorRequired => translate('trainerFormErrorRequired');
  String get trainerFormAgeLabel => translate('trainerFormAgeLabel');
  String get trainerFormAgeHint => translate('trainerFormAgeHint');
  String get trainerFormErrorAgeInvalid => translate('trainerFormErrorAgeInvalid');
  String get trainerFormSpecLabel => translate('trainerFormSpecLabel');
  String get trainerFormSpecHint => translate('trainerFormSpecHint');
  String get trainerFormExpLabel => translate('trainerFormExpLabel');
  String get trainerFormExpHint => translate('trainerFormExpHint');
  String get trainerFormContactLabel => translate('trainerFormContactLabel');
  String get trainerFormContactHint => translate('trainerFormContactHint');
  String get trainerFormProveLabel => translate('trainerFormProveLabel');
  String get trainerFormUploadHint => translate('trainerFormUploadHint');
  String get trainerFormButtonSubmit => translate('trainerFormButtonSubmit');
  String get trainerFormErrorComplete => translate('trainerFormErrorComplete');
  String get trainerFormErrorUpload => translate('trainerFormErrorUpload');
  String get trainerFormErrorNotLoggedIn => translate('trainerFormErrorNotLoggedIn');
  String get trainerFormSuccess => translate('trainerFormSuccess');
  String get trainerFormErrorPrefix => translate('trainerFormErrorPrefix');
  
  // consult screen
  String get errorSomethingWentWrong => translate('errorSomethingWentWrong');
  String get carouselTitle => translate('carouselTitle');
  String get carouselSubtitle => translate('carouselSubtitle');
  String get carouselButtonPending => translate('carouselButtonPending');
  String get carouselButtonApply => translate('carouselButtonApply');
  String get carouselButtonRequest => translate('carouselButtonRequest');
  String get trainerInstructionTitle => translate('trainerInstructionTitle');
  String get trainerInstructionPage1 => translate('trainerInstructionPage1');
  String get trainerInstructionPage2 => translate('trainerInstructionPage2');
  String get trainerInstructionPage3 => translate('trainerInstructionPage3');
  String get trainerInstructionButtonFinish => translate('trainerInstructionButtonFinish');
  String get trainerInstructionButtonNext => translate('trainerInstructionButtonNext');

  //admin user screen
  String adminUserErrorFetch(String error) =>
      translate('adminUserErrorFetch').replaceAll('{error}', error);
  String adminUserErrorUpdate(String error) =>
      translate('adminUserErrorUpdate').replaceAll('{error}', error);
  String adminUserFreezeSuccess(String username) =>
      translate('adminUserFreezeSuccess').replaceAll('{username}', username);
  String adminUserUnfreezeSuccess(String username) =>
      translate('adminUserUnfreezeSuccess').replaceAll('{username}', username);
  String get adminUserNoBio => translate('adminUserNoBio');
  String get adminUserButtonFreeze => translate('adminUserButtonFreeze');
  String get adminUserButtonUnfreeze => translate('adminUserButtonUnfreeze');

  // admin report
  String adminDataErrorLoad(String error) =>
      translate('adminDataErrorLoad').replaceAll('{error}', error);
  String get adminDataTotalUsers => translate('adminDataTotalUsers');
  String get adminDataUserGenders => translate('adminDataUserGenders');
  String get adminDataMale => translate('adminDataMale');
  String get adminDataFemale => translate('adminDataFemale');
  String get adminDataOverview => translate('adminDataOverview');
  String get adminDataAllMonths => translate('adminDataAllMonths');
  String get adminDataAvgCalories => translate('adminDataAvgCalories');
  String get adminDataTotalDuration => translate('adminDataTotalDuration');
  String get adminDataCaloriesBurnt => translate('adminDataCaloriesBurnt');
  String get adminDataNewUsers => translate('adminDataNewUsers');
  String get adminDataMonthJan => translate('adminDataMonthJan');
  String get adminDataMonthMar => translate('adminDataMonthMar');
  String get adminDataMonthMay => translate('adminDataMonthMay');
  String get adminDataMonthJul => translate('adminDataMonthJul');
  String get adminDataMonthSep => translate('adminDataMonthSep');
  String get adminDataMonthNov => translate('adminDataMonthNov');

  List<String> get monthsList => [
    translate('monthJanuary'),
    translate('monthFebruary'),
    translate('monthMarch'),
    translate('monthApril'),
    translate('monthMay'),
    translate('monthJune'),
    translate('monthJuly'),
    translate('monthAugust'),
    translate('monthSeptember'),
    translate('monthOctober'),
    translate('monthNovember'),
    translate('monthDecember'),
  ];

// Nav record screen
  String get recordTabOverview => translate('recordTabOverview');
// NavigationBar
  String get navDashboard => translate('navDashboard');
  String get navFriends => translate('navFriends');
  String get navCamera => translate('navCamera');
  String get navConsult => translate('navConsult');
  String get navRecords => translate('navRecords');
  String get recordTabTracker => translate('recordTabTracker');

  // DietScreen
  String get recordTabDiet => translate('recordTabDiet');
  String get recordTabExercise => translate('recordTabExercise');

  // For the Diet Screen
  String get recordSectionNutrition => translate('recordSectionNutrition');
  String get recordSectionMeals => translate('recordSectionMeals');
  String get recordNutrientProtein => translate('recordNutrientProtein');
  String get recordNutrientCarbs => translate('recordNutrientCarbs');
  String get recordNutrientFat => translate('recordNutrientFat');
  String get recordNutrientFiber => translate('recordNutrientFiber');
  String get recordNutrientCals => translate('recordNutrientCals');

  // For error/empty states
  String get recordError => translate('recordError');
  String get recordNoData => translate('recordNoData');

// camera
  String get cameraSourceTitle => translate('cameraSourceTitle');
  String get cameraSourceCamera => translate('cameraSourceCamera');
  String get cameraSourceGallery => translate('cameraSourceGallery');
  String get cameraNoImage => translate('cameraNoImage');
  String get cameraButton => translate('cameraButton');
  String get cameraError => translate('cameraError');
  String get cameraNoAnalysis => translate('cameraNoAnalysis');
  String get cameraUnknownMeal => translate('cameraUnknownMeal');
  String get cameraNoRecommendation => translate('cameraNoRecommendation');
  String get cameraNutrientProtein => translate('cameraNutrientProtein');
  String get cameraNutrientCarbs => translate('cameraNutrientCarbs');
  String get cameraNutrientFat => translate('cameraNutrientFat');
  String get cameraNutrientFiber => translate('cameraNutrientFiber');
  String get cameraSaving => translate('cameraSaving');
  String get cameraSave => translate('cameraSave');
  String get cameraPostStory => translate('cameraPostStory');
  String get cameraStoryAdded => translate('cameraStoryAdded');
  String get cameraMealSaveSuccess => translate('cameraMealSaveSuccess');
  String get cameraMealSaveError => translate('cameraMealSaveError');

  // request details
  String get adminRequestApproveSuccess => translate('adminRequestApproveSuccess');
  String adminRequestApproveError(String error) =>
      translate('adminRequestApproveError').replaceAll('{error}', error);
  String get adminRequestRejectReasonDefault => translate('adminRequestRejectReasonDefault');
  String get adminRequestRejectSuccess => translate('adminRequestRejectSuccess');
  String adminRequestRejectError(String error) =>
      translate('adminRequestRejectError').replaceAll('{error}', error);
  String get adminRequestHeaderInfo => translate('adminRequestHeaderInfo');
  String get adminRequestHeaderProve => translate('adminRequestHeaderProve');
  String get adminRequestNoCerts => translate('adminRequestNoCerts');
  String get adminRequestButtonApprove => translate('adminRequestButtonApprove');
  String get adminRequestButtonReject => translate('adminRequestButtonReject');
  String get adminRequestErrorLoadCert => translate('adminRequestErrorLoadCert');

  // admin request
  String adminRequestErrorLoad(String error) =>
      translate('adminRequestErrorLoad').replaceAll('{error}', error);
  String get adminRequestNoPending => translate('adminRequestNoPending');
  String get adminRequestSpecPrefix => translate('adminRequestSpecPrefix');

  // admin screen
  String get adminNavUsers => translate('adminNavUsers');
  String get adminNavRequests => translate('adminNavRequests');
  String get adminNavData => translate('adminNavData');

  // consult
  String get trainerListTitle => translate('trainerListTitle');
  String get trainerListNoTrainers => translate('trainerListNoTrainers');
  String get trainerListRequestTitle => translate('trainerListRequestTitle');
  String get trainerListRequestMessage => translate('trainerListRequestMessage');
  String trainerListRequestSent(String trainerName) =>
      translate('trainerListRequestSent').replaceAll('{trainerName}', trainerName);
  String get trainerListRequestTooltip => translate('trainerListRequestTooltip');
  String get consultChatWithTrainer => translate('consultChatWithTrainer');
  String get consultChatSubtitle => translate('consultChatSubtitle');
  String get consultGetTrainer => translate('consultGetTrainer');
  String get consultGetTrainerSubtitle => translate('consultGetTrainerSubtitle');
  String get consultTrainerSubtitle => translate('consultTrainerSubtitle');
  String get consultSuccessStory => translate('consultSuccessStory');
  String get consultWhyChooseUs => translate('consultWhyChooseUs');
  String get consultFeature1Title => translate('consultFeature1Title');
  String get consultFeature1Subtitle => translate('consultFeature1Subtitle');
  String get consultFeature2Title => translate('consultFeature2Title');
  String get consultFeature2Subtitle => translate('consultFeature2Subtitle');
  String get consultFeature3Title => translate('consultFeature3Title');
  String get consultFeature3Subtitle => translate('consultFeature3Subtitle');
  String get consultPendingSubtitle => translate('consultPendingSubtitle');


  // Login & Register
  String get appName => translate('appName');
  String get tagline => translate('tagline');

  String get emailLabel => translate('emailLabel');
  String get emailHint => translate('emailHint');
  String get emailErrorEmpty => translate('emailErrorEmpty');
  String get emailErrorInvalid => translate('emailErrorInvalid');

  String get passwordLabel => translate('passwordLabel');
  String get passwordHint => translate('passwordHint');
  String get passwordErrorEmpty => translate('passwordErrorEmpty');
  String get passwordErrorShort => translate('passwordErrorShort');

  String get forgotPassword => translate('forgotPassword');
  String get loginButton => translate('loginButton');
  String get noAccount => translate('noAccount');
  String get registerNow => translate('registerNow');
  String get loginError => translate('loginError');

  String get createAccount => translate('createAccount');

  String get usernameLabel => translate('usernameLabel');
  String get usernameHint => translate('usernameHint');
  String get usernameErrorEmpty => translate('usernameErrorEmpty');
  String get usernameErrorShort => translate('usernameErrorShort');

  String get confirmPasswordLabel => translate('confirmPasswordLabel');
  String get confirmPasswordHint => translate('confirmPasswordHint');
  String get confirmPasswordErrorEmpty =>
      translate('confirmPasswordErrorEmpty');
  String get confirmPasswordErrorMismatch =>
      translate('confirmPasswordErrorMismatch');

  String get registerButton => translate('registerButton');
  String get termsNotice => translate('termsNotice');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension for easy access
extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}
