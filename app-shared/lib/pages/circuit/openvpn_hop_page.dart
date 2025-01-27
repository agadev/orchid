import 'package:flutter/material.dart';
import 'package:orchid/pages/common/app_text_field.dart';
import 'package:orchid/pages/common/formatting.dart';
import 'package:orchid/pages/common/instructions_view.dart';
import 'package:orchid/pages/common/screen_orientation.dart';
import 'package:orchid/pages/common/tap_clears_focus.dart';
import 'package:orchid/pages/common/titled_page_base.dart';
import '../app_colors.dart';
import '../app_text.dart';
import 'hop_editor.dart';
import 'model/openvpn_hop.dart';

/// Create / edit / view an Open VPN Hop
class OpenVPNHopPage extends HopEditor<OpenVPNHop> {
  OpenVPNHopPage(
      {@required editableHop, mode = HopEditorMode.View, onAddFlowComplete})
      : super(
            editableHop: editableHop,
            mode: mode,
            onAddFlowComplete: onAddFlowComplete);

  @override
  _OpenVPNHopPageState createState() => _OpenVPNHopPageState();
}

class _OpenVPNHopPageState extends State<OpenVPNHopPage> {
  // TODO: Validation logic
  var _userName = TextEditingController();
  var _userPassword = TextEditingController();
  var _ovpnConfig = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Disable rotation until we update the screen design
    ScreenOrientation.portrait();

    OpenVPNHop hop = widget.editableHop.value?.hop;
    _userName.text = hop?.userName;
    _userPassword.text = hop?.userPassword;
    _ovpnConfig.text = hop?.ovpnConfig;
    setState(() {}); // Setstate to update the hop for any defaulted values.

    _userName.addListener(_updateHop);
    _userPassword.addListener(_updateHop);
    _ovpnConfig.addListener(_updateHop);
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _updateHop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: TapClearsFocus(
        child: TitledPage(
          title: "OpenVPNHop",
          lightTheme: false,
          actions: widget.mode == HopEditorMode.Create
              ? [widget.buildSaveButton(context)]
              : [],
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SafeArea(
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Text("Username",
                      style: AppText.textLabelStyle.copyWith(fontSize: 14.0)),
                  pady(8),
                  AppTextField(
                    hintText: "Username",
                    margin: EdgeInsets.zero,
                    controller: _userName,
                  ),
                  pady(16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[],
                  ),
                  Text("Password",
                      style: AppText.textLabelStyle.copyWith(fontSize: 14.0)),
                  pady(8),
                  AppTextField(
                    hintText: "Password",
                    margin: EdgeInsets.zero,
                    controller: _userPassword,
                  ),
                  pady(16),
                  Row(
                    children: <Widget>[
                      Text(
                        "Config",
                        style: AppText.textLabelStyle.copyWith(fontSize: 14.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      Image.asset(
                        "assets/images/info_outline.png",
                        height: 18,
                        color: AppColors.purple,
                      ),
                    ],
                  ),
                  Container(
                    height: 150.0,
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: SingleChildScrollView(
                        child: Stack(
                      children: <Widget>[
                        TextFormField(
                          autocorrect: false,
                          autofocus: false,
                          keyboardType: TextInputType.multiline,
                          style: AppText.logStyle
                              .copyWith(color: AppColors.grey_2),
                          controller: _ovpnConfig,
                          maxLines: 99999,
                          decoration: InputDecoration(
                            hintText: "Paste your OVPN config file here",
                            border: InputBorder.none,
                            labelStyle: AppText.textLabelStyle,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            Icons.content_paste,
                            color: AppColors.green_4,
                            size: 18.0,
                          ),
                        )
                      ],
                    )),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      border:
                          Border.all(width: 2.0, color: AppColors.neutral_5),
                    ),
                  ),
                  // Instructions
                  Visibility(
                    visible: widget.mode == HopEditorMode.Create,
                    child: Container(
                      height: 130.0,
                      width: double.infinity,
                      child: InstructionsView(
                        // TODO: This screen is being told it's in landscape mode in the simulator?
                        //hideInLandscape: false,
                        title: "Enter your credentials",
                        body:
                            "Enter the login information for your VPN provider above. Then paste the contents of your provider’s OpenVPN config file into the field provided. ",
                      ),
                    ),
                  ),
                  pady(24.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateHop() {
    if (!widget.editable()) {
      return;
    }
    widget.editableHop.update(OpenVPNHop(
        userName: _userName.text,
        userPassword: _userPassword.text,
        ovpnConfig: _ovpnConfig.text));
  }

  @override
  void dispose() {
    super.dispose();
    ScreenOrientation.reset();
    _userName.removeListener(_updateHop);
    _userPassword.removeListener(_updateHop);
    _ovpnConfig.removeListener(_updateHop);
  }
}
