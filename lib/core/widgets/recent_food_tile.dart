// import 'package:flutter/material.dart';
//
// import '../../features/home/model/home_models.dart';
// import '../utils/color_manager.dart';
// import '../utils/responsive_manager.dart';
//
// class RecentFoodTile extends StatelessWidget {
//   final RecentFoodUiModel item;
//   final VoidCallback onTap;
//
//   const RecentFoodTile({
//     super.key,
//     required this.item,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     ResponsiveManager.init(context);
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: EdgeInsets.only(bottom: ResponsiveManager.spacingMedium),
//         padding: EdgeInsets.all(ResponsiveManager.spacingMedium),
//         decoration: BoxDecoration(
//           color: context.surfaceColor,
//           borderRadius: BorderRadius.circular(ResponsiveManager.radiusLarge),
//           boxShadow: [
//             BoxShadow(
//               color: context.cardShadow,
//               blurRadius: ResponsiveManager.spacingLarge,
//               offset: Offset(0, ResponsiveManager.spacingSmall),
//             ),
//           ],
//           border: Border.all(color: context.dividerColor),
//         ),
//         child: Row(
//           children: [
//             ClipRRect(
//               borderRadius:
//                   BorderRadius.circular(ResponsiveManager.radiusMedium),
//               child: (item.imageAsset == null)
//                   ? _fallback(context)
//                   : Image.asset(
//                       item.imageAsset!,
//                       width: 60.w,
//                       height: 60.w,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => _fallback(context),
//                     ),
//             ),
//             SizedBox(width: ResponsiveManager.spacingMedium),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.name,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: ResponsiveManager.bodyMedium,
//                       fontWeight: FontWeight.w800,
//                       color: context.textColor,
//                     ),
//                   ),
//                   SizedBox(height: ResponsiveManager.spacingXSmall),
//                   Text(
//                     item.time,
//                     style: TextStyle(
//                       fontSize: ResponsiveManager.bodySmall,
//                       color: context.textSecondaryColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: ResponsiveManager.spacingMedium,
//                 vertical: ResponsiveManager.spacingXSmall,
//               ),
//               decoration: BoxDecoration(
//                 color: context.dividerColor,
//                 borderRadius: BorderRadius.circular(999),
//               ),
//               child: Text(
//                 "${item.calories} cal",
//                 style: TextStyle(
//                   fontSize: ResponsiveManager.caption,
//                   fontWeight: FontWeight.w700,
//                   color: context.textColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _fallback(BuildContext context) {
//     return Container(
//       width: 60.w,
//       height: 60.w,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: context.dividerColor,
//         borderRadius: BorderRadius.circular(ResponsiveManager.radiusMedium),
//       ),
//       child: Icon(
//         Icons.fastfood,
//         size: ResponsiveManager.iconMedium,
//         color: context.lightGrey,
//       ),
//     );
//   }
// }
