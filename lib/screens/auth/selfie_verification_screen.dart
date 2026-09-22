import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../services/profile_service.dart';

class SelfieVerificationScreen extends StatefulWidget {
  const SelfieVerificationScreen({
    super.key,
  });

  @override
  State<SelfieVerificationScreen> createState() =>
      _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState
    extends State<SelfieVerificationScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // CIVICID COLORS
  // ============================================================

  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF52635B);
  static const Color darkText = Color(0xFF14251C);

  final ProfileService _profileService = ProfileService();

  CameraController? _cameraController;

  bool _isCameraLoading = true;
  bool _isCameraReady = false;
  bool _isCapturing = false;
  bool _isSaving = false;
  bool _faceConfirmed = false;

  String? _cameraError;
  Uint8List? _selfieBytes;

  late final AnimationController _scanController;

  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _zoomAtGestureStart = 1.0;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1800,
      ),
    )..repeat();

    _initializeCamera();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _disposeCamera();
    super.dispose();
  }

  Future<void> _disposeCamera() async {
    final controller = _cameraController;
    _cameraController = null;

    if (controller != null) {
      try {
        await controller.dispose();
      } catch (_) {
        // Ignore disposal errors.
      }
    }
  }

  // ============================================================
  // CAMERA INITIALIZATION
  // ============================================================

  Future<void> _initializeCamera() async {
    await _disposeCamera();

    if (!mounted) {
      return;
    }

    setState(() {
      _isCameraLoading = true;
      _isCameraReady = false;
      _cameraError = null;
    });

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isCameraLoading = false;
          _isCameraReady = false;
          _cameraError =
          'No camera was found on this device.';
        });

        return;
      }

      CameraDescription selectedCamera =
          cameras.first;

      for (final camera in cameras) {
        if (camera.lensDirection ==
            CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _cameraController = controller;

      await controller.initialize();

      try {
        _minZoom = await controller.getMinZoomLevel();
        _maxZoom = await controller.getMaxZoomLevel();

        if (_maxZoom > 4.0) {
          _maxZoom = 4.0;
        }

        _currentZoom = _minZoom.clamp(
          _minZoom,
          _maxZoom,
        );
      } catch (_) {
        _minZoom = 1.0;
        _maxZoom = 1.0;
        _currentZoom = 1.0;
      }

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _isCameraLoading = false;
        _isCameraReady = true;
        _cameraError = null;
      });
    } on CameraException catch (e) {
      if (!mounted) {
        return;
      }

      String message;

      switch (e.code) {
        case 'CameraAccessDenied':
        case 'CameraAccessDeniedWithoutPrompt':
        case 'CameraAccessRestricted':
        case 'permissionDenied':
          message =
          'Camera permission was denied. Allow camera access in your browser and try again.';
          break;

        default:
          message =
          'The camera could not be started. Check your camera permission and try again.';
      }

      setState(() {
        _isCameraLoading = false;
        _isCameraReady = false;
        _cameraError = message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCameraLoading = false;
        _isCameraReady = false;
        _cameraError =
        'The camera could not be started. Check your browser camera permission and try again.';
      });
    }
  }

  // ============================================================
  // CAMERA ZOOM
  // ============================================================

  void _onScaleStart(
      ScaleStartDetails details,
      ) {
    _zoomAtGestureStart =
        _currentZoom;
  }

  Future<void> _onScaleUpdate(
      ScaleUpdateDetails details,
      ) async {
    final controller =
        _cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        _maxZoom <= _minZoom) {
      return;
    }

    final newZoom =
    (_zoomAtGestureStart *
        details.scale)
        .clamp(
      _minZoom,
      _maxZoom,
    );

    if ((newZoom - _currentZoom)
        .abs() <
        0.03) {
      return;
    }

    _currentZoom = newZoom;

    try {
      await controller.setZoomLevel(
        _currentZoom,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      // Some web cameras/browsers do not support zoom.
    }
  }

  // ============================================================
  // CAPTURE SELFIE
  // ============================================================

  Future<void> _captureSelfie() async {
    final controller = _cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile captured =
      await controller.takePicture();

      final bytes =
      await captured.readAsBytes();

      if (!mounted) {
        return;
      }

      await _disposeCamera();

      if (!mounted) {
        return;
      }

      setState(() {
        _selfieBytes = bytes;
        _faceConfirmed = false;
        _isCameraReady = false;
      });
    } on CameraException {
      if (!mounted) {
        return;
      }

      _showMessage(
        'The selfie could not be captured. Please try again.',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'The selfie could not be captured. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  // ============================================================
  // RETAKE
  // ============================================================

  Future<void> _retakeSelfie() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _selfieBytes = null;
      _faceConfirmed = false;
    });

    await _initializeCamera();
  }

  // ============================================================
  // SAVE SELFIE
  // ============================================================

  Future<void> _usePhoto() async {
    if (_selfieBytes == null) {
      _showMessage(
        'Please capture your selfie first.',
      );
      return;
    }

    if (!_faceConfirmed) {
      _showMessage(
        'Please confirm that your full face is clearly visible.',
      );
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final UserProfile profile =
      await _profileService.getProfile();

      final updatedProfile =
      profile.copyWith(
        registrationSelfieBase64:
        base64Encode(_selfieBytes!),
        identityVerificationStatus:
        'Pending Verification',
        identityVerificationComment: '',
        identityVerifiedBy: '',
      );

      await _profileService.updateProfile(
        updatedProfile,
      );

      if (!mounted) {
        return;
      }

      await _showSuccessDialog();

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Your selfie could not be saved. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          backgroundColor:
          Colors.white,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              22,
            ),
          ),
          title:
          const Row(
            children: [
              Icon(
                Icons
                    .verified_user_outlined,
                color: civicGreen,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Selfie Submitted',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content:
          const Text(
            'Your registration selfie has been submitted for identity verification. An authorized CivicID administrator can review it with your submitted details.',
            style: TextStyle(
              color: textGrey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              style:
              FilledButton
                  .styleFrom(
                backgroundColor:
                civicGreen,
                foregroundColor:
                Colors.white,
              ),
              child:
              const Text(
                'CONTINUE',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return PopScope(
      canPop:
      !_isCapturing &&
          !_isSaving,
      child: Scaffold(
        backgroundColor:
        pageBackground,

        appBar:
        AppBar(
          automaticallyImplyLeading:
          false,
          backgroundColor:
          Colors.white,
          surfaceTintColor:
          Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title:
          const Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Text(
                'Identity Verification',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
              Text(
                'Registration selfie',
                style: TextStyle(
                  color: textGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        body:
        SingleChildScrollView(
          padding:
          const EdgeInsets
              .fromLTRB(
            20,
            24,
            20,
            40,
          ),
          child: Center(
            child: Container(
              width:
              double.infinity,
              constraints:
              const BoxConstraints(
                maxWidth: 700,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  _buildIntroCard(),

                  const SizedBox(
                    height: 20,
                  ),

                  _buildCameraCard(),

                  const SizedBox(
                    height: 20,
                  ),

                  _buildInstructions(),

                  if (_selfieBytes !=
                      null) ...[
                    const SizedBox(
                      height: 20,
                    ),
                    _buildConfirmation(),
                  ],

                  const SizedBox(
                    height: 22,
                  ),

                  _buildActionButtons(),

                  const SizedBox(
                    height: 20,
                  ),

                  _buildPrivacyNotice(),

                  const SizedBox(
                    height: 12,
                  ),

                  _buildPrototypeNotice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INTRO
  // ============================================================

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(
        20,
      ),
      decoration:
      BoxDecoration(
        color: lightGreen,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color:
          const Color(
            0xFFCFE5D7,
          ),
        ),
      ),
      child:
      const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .face_retouching_natural_rounded,
            color: civicGreen,
            size: 30,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  'Live selfie required',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Use your device camera to take a new selfie now. Gallery and file uploads are not used on this registration step.',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CAMERA CARD
  // ============================================================

  Widget _buildCameraCard() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(
        14,
      ),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          24,
        ),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(
            20,
          ),
          child:
          _selfieBytes != null
              ? _buildCapturedPreview()
              : _buildLiveCamera(),
        ),
      ),
    );
  }

  Widget _buildLiveCamera() {
    if (_isCameraLoading) {
      return Container(
        color:
        const Color(
          0xFFF0F4F2,
        ),
        child:
        const Center(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: civicGreen,
              ),
              SizedBox(height: 16),
              Text(
                'Starting camera...',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Your browser may ask for camera permission.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color: textGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraError != null ||
        !_isCameraReady ||
        _cameraController ==
            null) {
      return Container(
        color:
        const Color(
          0xFFF4F7F5,
        ),
        padding:
        const EdgeInsets.all(
          24,
        ),
        child:
        Column(
          mainAxisAlignment:
          MainAxisAlignment
              .center,
          children: [
            const Icon(
              Icons
                  .videocam_off_outlined,
              color: textGrey,
              size: 55,
            ),
            const SizedBox(
              height: 14,
            ),
            const Text(
              'Camera unavailable',
              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight:
                FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              _cameraError ??
                  'The camera could not be opened.',
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                color: textGrey,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            FilledButton.icon(
              onPressed:
              _initializeCamera,
              icon:
              const Icon(
                Icons
                    .refresh_rounded,
              ),
              label:
              const Text(
                'TRY AGAIN',
              ),
              style:
              FilledButton
                  .styleFrom(
                backgroundColor:
                civicGreen,
                foregroundColor:
                Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final controller =
    _cameraController!;

    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio:
                controller
                    .value
                    .aspectRatio,
                child:
                CameraPreview(
                  controller,
                ),
              ),
            ),
          ),

          // Dark outside area + animated face scan ring.
          IgnorePointer(
            child: AnimatedBuilder(
              animation:
              _scanController,
              builder: (
                  context,
                  child,
                  ) {
                return CustomPaint(
                  painter:
                  _FaceScanPainter(
                    progress:
                    _scanController
                        .value,
                  ),
                  child:
                  const SizedBox
                      .expand(),
                );
              },
            ),
          ),

          // Zoom hint / zoom level.
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration:
              BoxDecoration(
                color: Colors.black
                    .withValues(
                  alpha: 0.55,
                ),
                borderRadius:
                BorderRadius
                    .circular(
                  20,
                ),
              ),
              child: Text(
                _maxZoom > _minZoom
                    ? '${_currentZoom.toStringAsFixed(1)}×  •  Pinch to zoom'
                    : 'Keep your face centered',
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child:
            Container(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration:
              BoxDecoration(
                color: Colors.black
                    .withValues(
                  alpha: 0.58,
                ),
                borderRadius:
                BorderRadius
                    .circular(
                  14,
                ),
              ),
              child:
              const Text(
                'Keep your full face inside the oval while the scan line moves around it',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color:
                  Colors.white,
                  fontSize: 13,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color:
          const Color(
            0xFFF0F4F2,
          ),
          child: Image.memory(
            _selfieBytes!,
            fit: BoxFit.contain,
          ),
        ),

        Positioned(
          left: 14,
          top: 14,
          child:
          Container(
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration:
            BoxDecoration(
              color: civicGreen,
              borderRadius:
              BorderRadius
                  .circular(
                20,
              ),
            ),
            child:
            const Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Icon(
                  Icons
                      .check_circle_rounded,
                  color:
                  Colors.white,
                  size: 17,
                ),
                SizedBox(width: 6),
                Text(
                  'SELFIE CAPTURED',
                  style: TextStyle(
                    color:
                    Colors.white,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INSTRUCTIONS
  // ============================================================

  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(
        18,
      ),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child:
      const Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Before taking your selfie',
            style: TextStyle(
              color: darkText,
              fontSize: 16,
              fontWeight:
              FontWeight.w900,
            ),
          ),
          SizedBox(height: 14),

          _InstructionRow(
            text:
            'Make sure your entire face is visible.',
          ),

          _InstructionRow(
            text:
            'Use a well-lit place.',
          ),

          _InstructionRow(
            text:
            'Look directly at the camera.',
          ),

          _InstructionRow(
            text:
            'Make sure only one person is visible.',
          ),

          _InstructionRow(
            text:
            'Avoid sunglasses, masks or anything covering important facial features.',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONFIRMATION
  // ============================================================

  Widget _buildConfirmation() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(
        14,
      ),
      decoration:
      BoxDecoration(
        color: lightGreen,
        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),
      child:
      CheckboxListTile(
        contentPadding:
        EdgeInsets.zero,
        value: _faceConfirmed,
        activeColor: civicGreen,
        controlAffinity:
        ListTileControlAffinity
            .leading,
        title:
        const Text(
          'I confirm that my full face is clearly visible in this selfie.',
          style: TextStyle(
            color: darkGreen,
            fontSize: 14,
            fontWeight:
            FontWeight.w700,
          ),
        ),
        onChanged:
        _isSaving
            ? null
            : (
            value,
            ) {
          setState(
                () {
              _faceConfirmed =
                  value ??
                      false;
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActionButtons() {
    if (_selfieBytes == null) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child:
        FilledButton.icon(
          onPressed:
          _isCameraReady &&
              !_isCapturing
              ? _captureSelfie
              : null,
          icon:
          _isCapturing
              ? const SizedBox(
            width: 19,
            height: 19,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color:
              Colors.white,
            ),
          )
              : const Icon(
            Icons
                .camera_alt_rounded,
          ),
          label: Text(
            _isCapturing
                ? 'CAPTURING...'
                : 'CAPTURE SELFIE',
          ),
          style:
          FilledButton
              .styleFrom(
            backgroundColor:
            civicGreen,
            foregroundColor:
            Colors.white,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width:
          double.infinity,
          height: 56,
          child:
          FilledButton.icon(
            onPressed:
            _isSaving
                ? null
                : _usePhoto,
            icon:
            _isSaving
                ? const SizedBox(
              width: 19,
              height: 19,
              child:
              CircularProgressIndicator(
                strokeWidth:
                2,
                color:
                Colors
                    .white,
              ),
            )
                : const Icon(
              Icons
                  .check_circle_outline_rounded,
            ),
            label: Text(
              _isSaving
                  ? 'SAVING...'
                  : 'USE THIS SELFIE',
            ),
            style:
            FilledButton
                .styleFrom(
              backgroundColor:
              civicGreen,
              foregroundColor:
              Colors.white,
            ),
          ),
        ),

        const SizedBox(
          height: 11,
        ),

        SizedBox(
          width:
          double.infinity,
          height: 52,
          child:
          OutlinedButton.icon(
            onPressed:
            _isSaving
                ? null
                : _retakeSelfie,
            icon:
            const Icon(
              Icons
                  .refresh_rounded,
            ),
            label:
            const Text(
              'RETAKE SELFIE',
            ),
            style:
            OutlinedButton
                .styleFrom(
              foregroundColor:
              civicGreen,
              side:
              const BorderSide(
                color:
                civicGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRIVACY
  // ============================================================

  Widget _buildPrivacyNotice() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(
        15,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFFFF8E7,
        ),
        borderRadius:
        BorderRadius.circular(
          15,
        ),
      ),
      child:
      const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .lock_outline_rounded,
            color:
            Color(
              0xFF9B7100,
            ),
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your selfie is sensitive personal information. In this prototype it should only be used for identity verification and only be accessible to you and authorized administrators.',
              style: TextStyle(
                color:
                Color(
                  0xFF725500,
                ),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrototypeNotice() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(
        14,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFF1F5F2,
        ),
        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),
      child:
      const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .school_outlined,
            color: textGrey,
            size: 19,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Academic Prototype — Not an official government service. This screen captures a live selfie but does not perform automated facial recognition.',
              style: TextStyle(
                color: textGrey,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionRow
    extends StatelessWidget {
  final String text;

  const _InstructionRow({
    required this.text,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons
                .check_circle_rounded,
            color:
            Color(
              0xFF08783E,
            ),
            size: 20,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              text,
              style:
              const TextStyle(
                color:
                Color(
                  0xFF52635B,
                ),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _FaceScanPainter
    extends CustomPainter {
  final double progress;

  _FaceScanPainter({
    required this.progress,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final ovalWidth =
    size.width < 420
        ? size.width * 0.58
        : 240.0;

    final ovalHeight =
        ovalWidth * 1.28;

    final rect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    // Dim the area outside the face oval.
    final fullPath = Path()
      ..addRect(
        Offset.zero & size,
      );

    final ovalPath = Path()
      ..addOval(rect);

    final outside = Path.combine(
      PathOperation.difference,
      fullPath,
      ovalPath,
    );

    final dimPaint = Paint()
      ..color = Colors.black
          .withValues(
        alpha: 0.28,
      );

    canvas.drawPath(
      outside,
      dimPaint,
    );

    // Base oval.
    final basePaint = Paint()
      ..color = Colors.white
          .withValues(
        alpha: 0.72,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(
      rect,
      basePaint,
    );

    // Moving green scan arc.
    final scanPaint = Paint()
      ..color =
      const Color(
        0xFF36D37E,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final startAngle =
        (progress * 6.28318530718) -
            1.57079632679;

    canvas.drawArc(
      rect,
      startAngle,
      1.35,
      false,
      scanPaint,
    );

    // Soft glow around moving arc.
    final glowPaint = Paint()
      ..color =
      const Color(
        0xFF36D37E,
      ).withValues(
        alpha: 0.25,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..maskFilter =
      const MaskFilter.blur(
        BlurStyle.normal,
        8,
      );

    canvas.drawArc(
      rect,
      startAngle,
      1.35,
      false,
      glowPaint,
    );

    // Small moving scan dot.
    final angle =
        startAngle + 1.35;

    final dotX =
        center.dx +
            (ovalWidth / 2) *
                0.98 *
                _cos(angle);

    final dotY =
        center.dy +
            (ovalHeight / 2) *
                0.98 *
                _sin(angle);

    canvas.drawCircle(
      Offset(
        dotX,
        dotY,
      ),
      5,
      Paint()
        ..color =
        const Color(
          0xFF8FF0B9,
        ),
    );
  }

  // Small trig approximations through dart's built-in double methods
  // are not available, so these delegate to math helpers below.
  double _sin(double x) =>
      _MathHelper.sin(x);

  double _cos(double x) =>
      _MathHelper.cos(x);

  @override
  bool shouldRepaint(
      covariant _FaceScanPainter
      oldDelegate,
      ) {
    return oldDelegate.progress !=
        progress;
  }
}

class _MathHelper {
  static double sin(
      double x,
      ) {
    // Taylor reduction is sufficient for the animated indicator.
    while (x > 3.14159265359) {
      x -= 6.28318530718;
    }

    while (x < -3.14159265359) {
      x += 6.28318530718;
    }

    final x2 = x * x;

    return x *
        (1 -
            x2 / 6 +
            x2 * x2 / 120 -
            x2 * x2 * x2 / 5040);
  }

  static double cos(
      double x,
      ) {
    return sin(
      x + 1.57079632679,
    );
  }
}
