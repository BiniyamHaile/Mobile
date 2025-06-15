// lib/constants/app_strings.dart

class AppStrings {
  // Prevent instantiation
  AppStrings._();

  // General
  static const String appTitle = 'app_title';
  static const String greeting = 'greeting';
  static const String languageSelect = 'language_select';

  // Auth Screens
  static const String welcomeLogin = 'welcome_login';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgotPassword = 'forgot_password';
  static const String resetPassword = 'reset_password';
  static const String email = 'email';
  static const String password = 'password';
  static const String confirmPassword = 'confirm_password';
  static const String dontHaveAccount = 'dont_have_account';
  static const String register = 'register';
  static const String emailRequired = 'email_required';
  static const String passwordRequired = 'password_required';
  static const String passwordMinLength = 'password_min_length';
  static const String passwordUppercase = 'password_uppercase';
  static const String passwordNumber = 'password_number';
  static const String passwordSpecialChar = 'password_special_char';
  static const String passwordMatch = 'password_match';
  static const String loginSuccess = 'login_success';
  static const String completeDetails = 'complete_details';
  static const String selectGender = 'select_gender';
  static const String male = 'male';
  static const String female = 'female';

  // ----


  static const String changePassword = 'change_password';
  static const String currentPassword = 'current_password';
  static const String passwordUpdatedSuccess = 'password_updated_success';
  static const String currentPasswordRequired = 'current_password_required';
  static const String newPassword = 'new_password';
  static const String newPasswordRequired = 'new_password_required';
  static const String pleaseConfirmPassword = 'please_confirm_new_password';



// ------

  // Profile
  static const String firstName = 'first_name';
  static const String lastName = 'last_name';
  static const String enterEmailForReset = 'enter_email_for_reset';
  static const String sendResetCode = 'send_reset_code';
  static const String backToLogin = 'back_to_login';
  static const String followers = 'followers';
  static const String following = 'following';
  static const String follow = 'follow';
  static const String message = 'message';
  static const String settings = 'settings';
  static const String more = 'more';

  // Post
  static const String mediaPreview = 'media_preview';
  static const String mentionedUsers = 'mentioned_users';
  static const String userNotFound = 'user_not_found';
  static const String postCreatedSuccess = 'post_created_success';
  static const String postUpdatedSuccess = 'post_updated_success';
  static const String postDeletedSuccess = 'post_deleted_success';
  static const String postNotFound = 'post_not_found';
  static const String editPost = 'edit_post';
  static const String createPost = 'create_post';
  static const String updatePost = 'update_post';
  static const String whatsOnYourMind = "whats_on_your_mind";
  static const String gallery = 'gallery';
  static const String video = 'video';
  static const String camera = 'camera';

  // Post Screen
  static const String addDescription = 'add_description';
  static const String posting = 'posting';
  static const String post = 'post';
  static const String reelPostedSuccess = 'reel_posted_success';
  static const String failedToPostReel = 'failed_to_post_reel';
  static const String errorSelectingPhotos = 'error_selecting_photos';
  static const String errorSelectingVideos = 'error_selecting_videos';
  static const String errorTakingPhoto = 'error_taking_photo';
  static const String addContentToPost = 'add_content_to_post';
  static const String postingServiceUnavailable = 'posting_service_unavailable';
  static const String postCreationFailed = 'post_creation_failed';
  static const String sharePost = 'share_post';
  static const String failedToSharePost = 'failed_to_share_post';
  static const String checkOutPost = 'check_out_post';

  // Report Page
  static const String reportPostTitle = 'report_post_title';
  static const String reportReasonQuestion = 'report_reason_question';
  static const String reportSubmittedSuccess = 'report_submitted_success';
  static const String submitReport = 'submit_report';
  static const String customReason = 'custom_reason';
  static const String specifyReason = 'specify_reason';

  // Report Categories
  static const String reportCatViolence = 'report_cat_violence';
  static const String reportCatHateSpeech = 'report_cat_hate_speech';
  static const String reportCatHarassment = 'report_cat_harassment';
  static const String reportCatNudity = 'report_cat_nudity';
  static const String reportCatFalseInfo = 'report_cat_false_info';
  static const String reportCatSpam = 'report_cat_spam';
  static const String reportCatOther = 'report_cat_other';

  // Report Sub-reasons
  static const String subAssault = 'sub_assault';
  static const String subThreats = 'sub_threats';
  static const String subAnimalCruelty = 'sub_animal_cruelty';
  static const String subRacist = 'sub_racist';
  static const String subSexist = 'sub_sexist';
  static const String subReligious = 'sub_religious';
  static const String subLgbtqTargeted = 'sub_lgbtq_targeted';
  static const String subRepeatedInsults = 'sub_repeated_insults';
  static const String subNameCalling = 'sub_name_calling';
  static const String subStalking = 'sub_stalking';
  static const String subExplicitPhotos = 'sub_explicit_photos';
  static const String subSexualLanguage = 'sub_sexual_language';
  static const String subMedical = 'sub_medical';
  static const String subPolitical = 'sub_political';
  static const String subOtherInfo = 'sub_other_info';
  static const String subClickbait = 'sub_clickbait';
  static const String subScamLinks = 'sub_scam_links';

  // Navigation
  static const String home = 'home';
  static const String reels = 'reels';
  static const String notifications = 'notifications';
  static const String profile = 'profile';
  static const String wallet = 'wallet';

  // Notifications
  static const String notificationChannelName = 'notification_channel_name';
  static const String notificationChannelDescription = 'notification_channel_description';
  static const String notificationTitle = 'notification_title';
  static const String notificationBody = 'notification_body';

  // Chat
  static const String photo = 'photo';
  static const String file = 'file';
  static const String cancel = 'cancel';
  static const String openLink = 'open_link';
  static const String openLinkQuestion = 'open_link_question';
  static const String openLinkDescription = 'open_link_description';
  static const String yes = 'yes';
  static const String no = 'no';
  static const String couldNotLaunchUrl = 'could_not_launch_url';
  static const String typing = 'typing';

  // Options Page
  static const String originalAudio = 'original_audio';
  static const String musicTrack = 'music_track';
  static const String likes = 'likes';
  static const String comments = 'comments';
  static const String share = 'share';

  // Wallet Screen
  static const String walletSettings = 'wallet_settings';
  static const String buyStars = 'buy_stars';
  static const String addStarsToken = 'add_stars_token';
  static const String disconnect = 'disconnect';
  static const String welcomeWallet = 'welcome_wallet';
  static const String connectWalletMessage = 'connect_wallet_message';
  static const String connectWallet = 'connect_wallet';
  static const String connectionFailed = 'connection_failed';
  static const String initializingWallet = 'initializing_wallet';
  static const String initializationFailed = 'initialization_failed';
  static const String token = 'token';
  static const String to = 'to';
  static const String from = 'from';
  static const String viewOnEtherscan = 'view_on_etherscan';
  static const String invalidAddress = 'invalid_address';
  static const String defaultRecipientNotSet = 'default_recipient_not_set';
  static const String invalidRecipientFormat = 'invalid_recipient_format';
  static const String connectSepoliaNetwork = 'connect_sepolia_network';
  static const String connectSepoliaNetworkGift = 'connect_sepolia_network_gift';
  static const String couldNotOpenTransaction = 'could_not_open_transaction';

  // OTP Screen
  static const String otpVerification = 'otp_verification';
  static const String enterOtpSent = 'enter_otp_sent';
  static const String verifyOtp = 'verify_otp';
  static const String resendOtp = 'resend_otp';
  static const String otpSent = 'otp_sent';
  static const String otpVerificationSuccess = 'otp_verification_success';
  static const String otpVerificationFailed = 'otp_verification_failed';
  static const String invalidOtp = 'invalid_otp';
  static const String verifying = 'verifying';
  static const String didntReceiveCode = 'didnt_receive_code';

  // Signup Validation
  static const String termsAndPrivacyRequired = 'terms_and_privacy_required';
  static const String nameRequired = 'name_required';
  static const String surnameRequired = 'surname_required';
  static const String emailInvalid = 'email_invalid';
  static const String passwordTooShort = 'password_too_short';
  static const String passwordNoUppercase = 'password_no_uppercase';
  static const String passwordNoNumber = 'password_no_number';
  static const String passwordNoSpecialChar = 'password_no_special_char';
  static const String passwordsDoNotMatch = 'passwords_do_not_match';
  static const String signupSuccess = 'signup_success';
  static const String signupFailed = 'signup_failed';
  static const String emailAlreadyExists = 'email_already_exists';

  // Profile Settings
  static const String settingsAndPrivacy = 'settings_and_privacy';
  static const String account = 'account';
  static const String changeProfilePicture = 'change_profile_picture';
  static const String contentPreferences = 'content_preferences';
  static const String supportAndAbout = 'support_and_about';
  static const String termsAndPolicies = 'terms_and_policies';
  static const String logOut = 'log_out';
  static const String logOutConfirmation = 'log_out_confirmation';
  static const String loggedOutSuccess = 'logged_out_success';
  static const String chooseProfilePic = 'choose_profile_pic';
  static const String update = 'update';
  static const String profilePicUpdated = 'profile_pic_updated';

  // Content Preferences
  static const String selectPreferences = 'select_preferences';
  static const String selectTopics = 'select_topics';
  static const String personalizeExperience = 'personalize_experience';
  static const String continueText = 'continue';
  static const String profileUpdatedSuccess = 'profile_updated_success';
  static const String failedToLoadPreferences = 'failed_to_load_preferences';
  static const String retry = 'retry';

  // User Profile
  static const String gift = 'gift';

  // Search Page
  static const String search = 'search';
  static const String all = 'all';
  static const String people = 'people';
  static const String posts = 'posts';
  static const String videos = 'videos';
  static const String searchHint = 'search_hint';
  static const String noResultsFound = 'no_results_found';
  static const String searchPeople = 'search_people';
  static const String searchPosts = 'search_posts';
  static const String searchVideos = 'search_videos';

  // Share and Gift
  static const String shareTo = 'share_to';
  static const String copyLink = 'copy_link';
  static const String linkCopied = 'link_copied';
  static const String giftStars = 'gift_stars';
  static const String enterAmount = 'enter_amount';
  static const String sendGift = 'send_gift';
  static const String giftSent = 'gift_sent';
  static const String giftFailed = 'gift_failed';

  // New strings from post_card.dart
  static const String pleaseConnectWalletToSendStarReactions = 'please_connect_wallet_to_send_star_reactions';
  static const String pleaseConnectToSepoliaNetworkToGiftStars = 'please_connect_to_sepolia_network_to_gift_stars';
  static const String recipientWalletAddressNotAvailableForThisPostAuthor = 'recipient_wallet_address_not_available_for_this_post_author';
  static const String invalidRecipientAddressFormatForThisPostAuthor = 'invalid_recipient_address_format_for_this_post_author';
  static const String postAuthor = 'post_author';
  static const String pleaseLoginToLikePosts = 'please_login_to_like_posts';
  static const String deletePost = 'delete_post';
  static const String repostPost = 'repost_post';
  static const String postReposted = 'post_reposted';

  // New AppStrings keys for language setting UI
  static const String language = 'language';
  static const String amharic = 'amharic';
  static const String afaanOromo = 'afaan_oromo';
  static const String english = 'english';
  static const String selectLanguage = 'select_language';

  static const String waitingForVideoDuration = 'waiting_for_video_duration';
  static const String postUpdateFailed = 'post_update_failed';

}
