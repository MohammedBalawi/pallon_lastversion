import 'package:flutter/material.dart';

import '../../../models/banner_model.dart';
import '../widget/edit_banner_widget.dart';


class EditBannerView extends StatelessWidget{
  BannerModel _bannerModel;
  EditBannerView(this._bannerModel);
  @override
  Widget build(BuildContext context) {
    return EditBannerWidget(_bannerModel);
  }
}