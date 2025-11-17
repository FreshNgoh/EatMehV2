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
  String get consultHeaderTitle => translate('consultHeaderTitle');
  String get consultHeaderSubtitle => translate('consultHeaderSubtitle');
  String get trainerInstructionPage1Title => translate('trainerInstructionPage1Title');
  String get trainerInstructionPage1Sub => translate('trainerInstructionPage1Sub');
  String get trainerInstructionPage2Title => translate('trainerInstructionPage2Title');
  String get trainerInstructionPage2Sub => translate('trainerInstructionPage2Sub');
  String get trainerInstructionPage3Title => translate('trainerInstructionPage3Title');
  String get trainerInstructionPage3Sub => translate('trainerInstructionPage3Sub');
  String get trainerInstructionButtonSkip => translate('trainerInstructionButtonSkip');

  String get traineeListSearchHint => translate('traineeListSearchHint');
  String get traineeListEmptyTitle => translate('traineeListEmptyTitle');
  String get traineeListEmptySubtitle => translate('traineeListEmptySubtitle');
  String get traineeListNoResultsTitle => translate('traineeListNoResultsTitle');
  String get traineeListNoResultsSubtitle => translate('traineeListNoResultsSubtitle');
  String get traineeListClearSearch => translate('traineeListClearSearch');

  // Chat Room
  String get chatErrorNotLoggedIn => translate('chatErrorNotLoggedIn');
  String chatErrorLoadMessages(String error) =>
      translate('chatErrorLoadMessages').replaceAll('{error}', error);
  String get chatEmptyState => translate('chatEmptyState');
  String get chatInputHint => translate('chatInputHint');

  String get trainerListDefaultName => translate('trainerListDefaultName');
  String get trainerListRequestExists => translate('trainerListRequestExists');

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

  // Trainer Requests Screen
  String get trainerReqTitleSingle => translate('trainerReqTitleSingle');
  String get trainerReqTitleMultiple => translate('trainerReqTitleMultiple');
  String get trainerReqErrorLoad => translate('trainerReqErrorLoad');
  String get trainerReqFilteredEmptyTitle => translate('trainerReqFilteredEmptyTitle');
  String get trainerReqFilteredEmptySubtitle => translate('trainerReqFilteredEmptySubtitle');
  String get trainerReqFilteredEmptyButton => translate('trainerReqFilteredEmptyButton');
  String get trainerReqEmptyTitle => translate('trainerReqEmptyTitle');
  String get trainerReqEmptySubtitle => translate('trainerReqEmptySubtitle');
  String get trainerReqDefaultUserName => translate('trainerReqDefaultUserName');
  String get trainerReqDefaultTraineeName => translate('trainerReqDefaultTraineeName');
  String get trainerReqTooltipAccept => translate('trainerReqTooltipAccept');
  String get trainerReqTooltipReject => translate('trainerReqTooltipReject');
  String get trainerReqDialogAcceptTitle => translate('trainerReqDialogAcceptTitle');
  String trainerReqDialogAcceptMsg(String name) =>
      translate('trainerReqDialogAcceptMsg').replaceAll('{name}', name);
  String get trainerReqDialogAcceptButton => translate('trainerReqDialogAcceptButton');
  String get trainerReqDialogRejectTitle => translate('trainerReqDialogRejectTitle');
  String trainerReqDialogRejectMsg(String name) =>
      translate('trainerReqDialogRejectMsg').replaceAll('{name}', name);
  String get trainerReqDialogRejectButton => translate('trainerReqDialogRejectButton');
  String get trainerReqDialogCancelButton => translate('trainerReqDialogCancelButton');
  String get trainerReqNotifAcceptTitle => translate('trainerReqNotifAcceptTitle');
  String get trainerReqNotifAcceptMsg => translate('trainerReqNotifAcceptMsg');
  String get trainerReqNotifRejectTitle => translate('trainerReqNotifRejectTitle');
  String get trainerReqNotifRejectMsg => translate('trainerReqNotifRejectMsg');
  String trainerReqSnackbarAcceptSuccess(String name) =>
      translate('trainerReqSnackbarAcceptSuccess').replaceAll('{name}', name);
  String trainerReqSnackbarAcceptError(String error) =>
      translate('trainerReqSnackbarAcceptError').replaceAll('{error}', error);
  String trainerReqSnackbarRejectSuccess(String name) =>
      translate('trainerReqSnackbarRejectSuccess').replaceAll('{name}', name);
  String trainerReqSnackbarRejectError(String error) =>
      translate('trainerReqSnackbarRejectError').replaceAll('{error}', error);
  String get trainerReqSheetSubtitle => translate('trainerReqSheetSubtitle');
  String get trainerReqSheetMsgLabel => translate('trainerReqSheetMsgLabel');

  // Trainer Set Goal
  String get trainerGoalErrorTitle => translate('trainerGoalErrorTitle');
  String get trainerGoalErrorNotFound => translate('trainerGoalErrorNotFound');
  String get trainerGoalTitle => translate('trainerGoalTitle');
  String get trainerGoalUserIDCopied => translate('trainerGoalUserIDCopied');
  String trainerGoalUserHope(String name, String goal) =>
      translate('trainerGoalUserHope').replaceAll('{name}', name).replaceAll('{goal}', goal);
  String get trainerGoalSectionTitle => translate('trainerGoalSectionTitle');
  String get trainerGoalCaloriesLabel => translate('trainerGoalCaloriesLabel');
  String get trainerGoalCaloriesHint => translate('trainerGoalCaloriesHint');
  String get trainerGoalProteinLabel => translate('trainerGoalProteinLabel');
  String get trainerGoalProteinHint => translate('trainerGoalProteinHint');
  String get trainerGoalCarbsLabel => translate('trainerGoalCarbsLabel');
  String get trainerGoalCarbsHint => translate('trainerGoalCarbsHint');
  String get trainerGoalFatLabel => translate('trainerGoalFatLabel');
  String get trainerGoalFatHint => translate('trainerGoalFatHint');
  String get trainerGoalFiberLabel => translate('trainerGoalFiberLabel');
  String get trainerGoalFiberHint => translate('trainerGoalFiberHint');
  String get trainerGoalStartDateLabel => translate('trainerGoalStartDateLabel');
  String get trainerGoalStartDateHint => translate('trainerGoalStartDateHint');
  String get trainerGoalEndDateLabel => translate('trainerGoalEndDateLabel');
  String get trainerGoalEndDateHint => translate('trainerGoalEndDateHint');
  String get trainerGoalSavingButton => translate('trainerGoalSavingButton');
  String get trainerGoalSaveButton => translate('trainerGoalSaveButton');
  String get trainerGoalSaveSuccess => translate('trainerGoalSaveSuccess');
  String trainerGoalSaveError(String error) =>
      translate('trainerGoalSaveError').replaceAll('{error}', error);

  // Stories Feed
  String storiesErrorLoad(String error) =>
      translate('storiesErrorLoad').replaceAll('{error}', error);
  String get storiesYou => translate('storiesYou');
  String get storiesYourStory => translate('storiesYourStory');
  String get storiesViewProfile => translate('storiesViewProfile');
  String get storiesNoFriendsTitle => translate('storiesNoFriendsTitle');
  String get storiesNoFriendsSubtitle => translate('storiesNoFriendsSubtitle');
  String get storiesCountSingular => translate('storiesCountSingular');
  String get storiesCountPlural => translate('storiesCountPlural');
  String get storiesNoStory => translate('storiesNoStory');
  String get storiesTimestampJustNow => translate('storiesTimestampJustNow');
  String storiesTimestampMinutesAgo(int minutes) =>
      translate('storiesTimestampMinutesAgo').replaceAll('{minutes}', minutes.toString());
  String storiesTimestampHoursAgo(int hours) =>
      translate('storiesTimestampHoursAgo').replaceAll('{hours}', hours.toString());
  String storiesTimestampDaysAgo(int days) =>
      translate('storiesTimestampDaysAgo').replaceAll('{days}', days.toString());

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

  // Story Viewer
  String storyViewerErrorComment(String error) =>
      translate('storyViewerErrorComment').replaceAll('{error}', error);
  String get storyViewerButtonSendMessage => translate('storyViewerButtonSendMessage');
  String get storyViewerButtonViewComment => translate('storyViewerButtonViewComment');
  String storyViewerButtonViewComments(int count) =>
      translate('storyViewerButtonViewComments').replaceAll('{count}', count.toString());
  String get storyViewerSheetTitle => translate('storyViewerSheetTitle');
  String get storyViewerEmptyTitle => translate('storyViewerEmptyTitle');
  String get storyViewerEmptySubtitle => translate('storyViewerEmptySubtitle');
  String get storyViewerInputHint => translate('storyViewerInputHint');

  // Profile Screen
  String get profileErrorUserNotFound => translate('profileErrorUserNotFound');
  String profileErrorLoadFailed(String error) =>
      translate('profileErrorLoadFailed').replaceAll('{error}', error);
  String get profileBioUpdateSuccess => translate('profileBioUpdateSuccess');
  String profileBioUpdateError(String error) =>
      translate('profileBioUpdateError').replaceAll('{error}', error);
  String get profileTitleLoading => translate('profileTitleLoading');
  String get profileTitleError => translate('profileTitleError');
  String profileErrorGeneric(String error) =>
      translate('profileErrorGeneric').replaceAll('{error}', error);
  String get profileErrorRetryButton => translate('profileErrorRetryButton');
  String get profileTitleOwn => translate('profileTitleOwn');
  String get profileCopiedToClipboard => translate('profileCopiedToClipboard');
  String get profileBioEmptyOwn => translate('profileBioEmptyOwn');
  String get profileBioEmptyOther => translate('profileBioEmptyOther');
  String get profileBadgeTrainer => translate('profileBadgeTrainer');
  String get profileTabMe => translate('profileTabMe');
  String get profileTabConsult => translate('profileTabConsult');
  String get profileConsultEmptyOwn => translate('profileConsultEmptyOwn');
  String get profileConsultEmptyOther => translate('profileConsultEmptyOther');
  String get profileBioCancel => translate('profileBioCancel');
  String get profileBioTitle => translate('profileBioTitle');
  String get profileBioSave => translate('profileBioSave');
  String get profileBioHint => translate('profileBioHint');


  // Login & Register
  String get appName => translate('appName');
  String get tagline => translate('tagline');

  // Profile Me Tab
  String get profileMeTodayStatus => translate('profileMeTodayStatus');
  String get profileMeKcal => translate('profileMeKcal');
  String get profileMeTaken => translate('profileMeTaken');
  String get profileMeBurnt => translate('profileMeBurnt');
  String profileMeKcalValue(int value) =>
      translate('profileMeKcalValue').replaceAll('{value}', value.toString());
  String get profileMeFriends => translate('profileMeFriends');
  String get profileMeTrainer => translate('profileMeTrainer');

  // Settings Screen
  String settingsLogoutError(String error) =>
      translate('settingsLogoutError').replaceAll('{error}', error);
  String get settingsTitle => translate('settingsTitle');
  String get settingsSectionTheme => translate('settingsSectionTheme');
  String get settingsThemeLight => translate('settingsThemeLight');
  String get settingsThemeDark => translate('settingsThemeDark');
  String get settingsSectionNotifications => translate('settingsSectionNotifications');
  String get settingsNotificationsEnable => translate('settingsNotificationsEnable');
  String get settingsSectionLanguage => translate('settingsSectionLanguage');
  String get settingsLanguageSelect => translate('settingsLanguageSelect');
  String get settingsLanguageEnglish => translate('settingsLanguageEnglish');
  String get settingsLanguageChinese => translate('settingsLanguageChinese');
  String get settingsLanguageSuccess => translate('settingsLanguageSuccess');
  String get settingsSectionOther => translate('settingsSectionOther');
  String get settingsOtherUserManual => translate('settingsOtherUserManual');
  String get settingsOtherSignOut => translate('settingsOtherSignOut');

  // Friend Request Button
  String get friendButtonSuccessRemoved => translate('friendButtonSuccessRemoved');
  String get friendButtonSuccessCancelled => translate('friendButtonSuccessCancelled');
  String get friendButtonSuccessSent => translate('friendButtonSuccessSent');
  String friendButtonError(String error) =>
      translate('friendButtonError').replaceAll('{error}', error);
  String get friendButtonSuccessAccepted => translate('friendButtonSuccessAccepted');
  String get friendButtonSuccessDeleted => translate('friendButtonSuccessDeleted');
  String get friendButtonLabelConfirm => translate('friendButtonLabelConfirm');
  String get friendButtonLabelDelete => translate('friendButtonLabelDelete');
  String get friendButtonLabelFriends => translate('friendButtonLabelFriends');
  String get friendButtonLabelRequesting => translate('friendButtonLabelRequesting');
  String get friendButtonLabelRequest => translate('friendButtonLabelRequest');

  // Dashboard
  String dashboardHello(String username) =>
      translate('dashboardHello').replaceAll('{username}', username);
  String get dashboardHeight => translate('dashboardHeight');
  String get dashboardWeight => translate('dashboardWeight');
  String dashboardUnitCm(String value) =>
      translate('dashboardUnitCm').replaceAll('{value}', value);
  String dashboardUnitKg(String value) =>
      translate('dashboardUnitKg').replaceAll('{value}', value);
  String get dashboardBMI => translate('dashboardBMI');
  String get dashboardCalorieGuide => translate('dashboardCalorieGuide');
  String get dashboardCalorieLow => translate('dashboardCalorieLow');
  String get dashboardCalorieHealthy => translate('dashboardCalorieHealthy');
  String get dashboardCalorieHigh => translate('dashboardCalorieHigh');
  String get dashboardTodayNutrition => translate('dashboardTodayNutrition');
  String get dashboardTodayExercise => translate('dashboardTodayExercise');
  String get dashboardTodayMeals => translate('dashboardTodayMeals');
  String dashboardUnitGram(String value) =>
      translate('dashboardUnitGram').replaceAll('{value}', value);

  // Edit Profile
  String get editProfileTitle => translate('editProfileTitle');
  String get editProfileReloginWarning => translate('editProfileReloginWarning');
  String editProfilePasswordUpdateFailed(String error) =>
      translate('editProfilePasswordUpdateFailed').replaceAll('{error}', error);
  String get editProfileUpdateSuccess => translate('editProfileUpdateSuccess');
  String editProfileUpdateFailed(String error) =>
      translate('editProfileUpdateFailed').replaceAll('{error}', error);
  String get genderMale => translate('genderMale');
  String get genderFemale => translate('genderFemale');
  String get dietVegetarian => translate('dietVegetarian');
  String get dietVegan => translate('dietVegan');
  String get dietOmnivore => translate('dietOmnivore');
  String get dietPescatarian => translate('dietPescatarian');
  String get bioLabel => translate('bioLabel');
  String get bioHint => translate('bioHint');
  String get bioErrorMaxLen => translate('bioErrorMaxLen');
  String get ageErrorRequired => translate('ageErrorRequired');
  String get genderLabel => translate('genderLabel');
  String get dietTypeLabel => translate('dietTypeLabel');
  String get heightLabel => translate('heightLabel');
  String get heightHint => translate('heightHint');
  String get heightErrorRequired => translate('heightErrorRequired');
  String get heightErrorInvalid => translate('heightErrorInvalid');
  String get weightLabel => translate('weightLabel');
  String get weightHint => translate('weightHint');
  String get weightErrorRequired => translate('weightErrorRequired');
  String get weightErrorInvalid => translate('weightErrorInvalid');
  String get bmiLabel => translate('bmiLabel');
  String get bmiHint => translate('bmiHint');
  String get newPasswordLabel => translate('newPasswordLabel');
  String get newPasswordHint => translate('newPasswordHint');
  String get updateButton => translate('updateButton');

  // Friends Screen
  String friendsErrorLoadRequests(String error) =>
      translate('friendsErrorLoadRequests').replaceAll('{error}', error);
  String friendsErrorSearch(String error) =>
      translate('friendsErrorSearch').replaceAll('{error}', error);
  String friendsErrorAccept(String error) =>
      translate('friendsErrorAccept').replaceAll('{error}', error);
  String get friendsRequestRejected => translate('friendsRequestRejected');
  String friendsErrorReject(String error) =>
      translate('friendsErrorReject').replaceAll('{error}', error);
  String get friendsTabFindFriends => translate('friendsTabFindFriends');
  String get friendsSearchHint => translate('friendsSearchHint');
  String get friendsSearchPrompt => translate('friendsSearchPrompt');
  String get friendsSearchNoResults => translate('friendsSearchNoResults');
  String get friendsRequestsEmpty => translate('friendsRequestsEmpty');

  // Notifications Screen
  String get notificationsFilterAll => translate('notificationsFilterAll');
  String get notificationsFilterStoryViews =>
      translate('notificationsFilterStoryViews');
  String get notificationsFilterMealReminders =>
      translate('notificationsFilterMealReminders');
  String notificationsErrorRole(String error) =>
      translate('notificationsErrorRole').replaceAll('{error}', error);
  String get notificationsEmptyTitle => translate('notificationsEmptyTitle');
  String get notificationsEmptySubtitle =>
      translate('notificationsEmptySubtitle');
  String notificationsEmptyFiltered(String filterName) =>
      translate('notificationsEmptyFiltered')
          .replaceAll('{filterName}', filterName);
  String get notificationsDeleteTitle => translate('notificationsDeleteTitle');
  String notificationsDeleteContent(String title) =>
      translate('notificationsDeleteContent').replaceAll('{title}', title);
  String get notificationsDeleted => translate('notificationsDeleted');
  String get notificationsUndo => translate('notificationsUndo');
  String notificationsTimestampWeeksAgo(int weeks) =>
      translate('notificationsTimestampWeeksAgo')
          .replaceAll('{weeks}', weeks.toString());
  String notificationsTimestampMonthsAgo(int months) =>
      translate('notificationsTimestampMonthsAgo')
          .replaceAll('{months}', months.toString());

  // User Manual
  String get manualStepScan => translate('manualStepScan');
  String get manualStepStory => translate('manualStepStory');
  String get manualStepRecord => translate('manualStepRecord');
  String get manualStepTrainee => translate('manualStepTrainee');
  String get manualStepTrainer => translate('manualStepTrainer');
  String manualStepCounter(int current, int total) =>
      translate('manualStepCounter')
          .replaceAll('{current}', current.toString())
          .replaceAll('{total}', total.toString());
  String get manualButtonPrevious => translate('manualButtonPrevious');
  String get manualButtonNext => translate('manualButtonNext');

  // User Feedback Screen
  String get feedbackErrorSelectRating => translate('feedbackErrorSelectRating');
  String get feedbackSuccessSubmitted => translate('feedbackSuccessSubmitted');
  String get feedbackSuccessUpdated => translate('feedbackSuccessUpdated');
  String feedbackErrorSubmit(String error) =>
      translate('feedbackErrorSubmit').replaceAll('{error}', error);
  String get feedbackErrorTrainerNotFound =>
      translate('feedbackErrorTrainerNotFound');
  String get feedbackTitle => translate('feedbackTitle');
  String get feedbackTrainerIDCopied => translate('feedbackTrainerIDCopied');
  String feedbackTrainingDuration(int months) {
    if (months == 1) {
      return translate('feedbackTrainingDurationMonth')
          .replaceAll('{months}', months.toString());
    }
    return translate('feedbackTrainingDurationMonths')
        .replaceAll('{months}', months.toString());
  }
  String get feedbackTrainingDurationRecent =>
      translate('feedbackTrainingDurationRecent');
  String get feedbackUpdateRatingTitle => translate('feedbackUpdateRatingTitle');
  String get feedbackRateExperienceTitle =>
      translate('feedbackRateExperienceTitle');
  String feedbackRatingPrompt(String name) =>
      translate('feedbackRatingPrompt').replaceAll('{name}', name);
  String get feedbackRatingPoor => translate('feedbackRatingPoor');
  String get feedbackRatingFair => translate('feedbackRatingFair');
  String get feedbackRatingGood => translate('feedbackRatingGood');
  String get feedbackRatingVeryGood => translate('feedbackRatingVeryGood');
  String get feedbackRatingExcellent => translate('feedbackRatingExcellent');
  String get feedbackSubmitButton => translate('feedbackSubmitButton');
  String get feedbackSendFriendRequest => translate('feedbackSendFriendRequest');
  String get feedbackChangeTrainer => translate('feedbackChangeTrainer');
  String get feedbackChangeTrainerConfirmMsg =>
      translate('feedbackChangeTrainerConfirmMsg');
  String get feedbackChangeTrainerSuccessMsg =>
      translate('feedbackChangeTrainerSuccessMsg');
  String feedbackErrorChangeTrainer(String error) =>
      translate('feedbackErrorChangeTrainer').replaceAll('{error}', error);

  String get emailLabel => translate('emailLabel');
  String get emailHint => translate('emailHint');
  String get emailErrorEmpty => translate('emailErrorEmpty');
  String get emailErrorInvalid => translate('emailErrorInvalid');

  // User Goals
  String get userGoalTitle => translate('userGoalTitle');
  String get userGoalSubtitle => translate('userGoalSubtitle');
  String get userGoalLoseWeightTitle => translate('userGoalLoseWeightTitle');
  String get userGoalLoseWeightDesc => translate('userGoalLoseWeightDesc');
  String get userGoalMaintainWeightTitle =>
      translate('userGoalMaintainWeightTitle');
  String get userGoalMaintainWeightDesc =>
      translate('userGoalMaintainWeightDesc');
  String get userGoalGainWeightTitle => translate('userGoalGainWeightTitle');
  String get userGoalGainWeightDesc => translate('userGoalGainWeightDesc');

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
