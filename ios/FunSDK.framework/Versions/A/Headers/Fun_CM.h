/*********************************************************************************
*Author:	Yongjun Zhao
*Description:  
*History:  
Date:	2017.11.03/Yongjun Zhao
Action:Create
**********************************************************************************/
#pragma once
#include "XTypes.h"
#define N_MAX_DOWNLOAD_QUEUE_SIZE 32

//EMSG_MC_SearchMediaByMoth = 6202
// < 0 failed  >= 0 success
//日历功能(可同时查看视频节点 和 报警消息节点)
int MC_SearchMediaByMoth(UI_HANDLE hUser, const char *devId, int nChannel, const char *szStreamType, int nDate, int nSeq = 0);

//EMSG_MC_SearchMediaByTime = 6203,
//查询时间段内的报警视频片段
int MC_SearchMediaByTime(UI_HANDLE hUser, const char *devId, int nChannel, const char *szStreamType, int nStartTime, int nEndTime, int nSeq = 0);

/*******************设备相关接口**************************
 * 方法名: 云存储视频查询
 * 描  述: 云存储视频查询
 * 返回值:[无]
 * 参  数:
 *      输入(in)
 *          [sDevId:设备序列号]
 *          [nChannel:通道号]
 *          [sStreamType:主辅码流 "Main"]
 *          [nStartTime:开始时间] // 短视频，某一时间点，开始时间往前推移5s，结束时间往后推移10s
 *          [nEndTime:结束时间]
 *          [sMessageType:消息类型：短视频：MSG_SHORT_VIDEO_QUERY_REQ，报警视频：MSG_ALARM_VIDEO_QUERY_REQ ]
 *          [bTimePoint:是否按时间点查询:TRUE/FALSE]
 *      输出(out)
 *          [无]
 * 结果消息：
 *          消息id:EMSG_MC_SearchMediaByTime = 6203
 *          param1: <0失败，详见错误码
 *          Str:查询到的结果，json信息
 * // 短视频查询逻辑是: 如果你给的时间段和视频的实际时间段有交集就会返回
 * // 普通视频查询逻辑是： 你给的时间段必须包含视频实际的时间段
 ****************************************************/
int MC_SearchMediaByTimeV2(UI_HANDLE hUser, const char *sDevId, int nChannel, const char *sStreamType, int nStartTime, int nEndTime, const char* sMessageType, Bool bTimePoint = FALSE, int nSeq = 0);

// 下载录像等媒体的缩略图
// EMSG_MC_DownloadMediaThumbnail = 6204,
// nWidth,nHeight可以指定宽和高，等于0时默认为原始大小
int MC_DownloadThumbnail(UI_HANDLE hUser, const char *devId, const char *szJson, const char *szFileName, int nWidth = 0, int nHeight = 0, int nSeq = 0);

/*******************设备相关接口**************************
 * 方法名: 云视频片段缩略图下载
 * 描  述: 云视频片段缩略图下载，通过开始时间和结束时间SDK内部自己查询,
 *      默认最大等待下载队列32个，超过会被清除，可通过MC_SetDownloadThumbnailMaxQueue进行设置，
 *      可通过MC_StopDownloadThumbnail清空下载队列
 * 返回值:[无]
 * 参  数:
 *      输入(in)
 *          [sDevId:设备序列号]
 *          [sFileName:下载图片绝对路径]
 *          [sStreamType:主辅码流  默认:"Main"]
 *          [sMessageType:消息类型:报警视频：MSG_ALARM_VIDEO_QUERY_REQ,短视频：MSG_SHORT_VIDEO_QUERY_REQ]
 *          [nChannel:通道号]
 *          [nStartTime:开始时间]
 *          [nEndTime:结束时间]
 *          [nWidth:缩略图宽度] // 等于0时默认为原始大小
 *          [nHeight:缩略图高度] //等于0时默认为原始大小
 *          [bTimePoint:是否按时间点查询:TRUE/FALSE]
 *      输出(out)
 *          [无]
 * 结果消息：
 *          消息id:EMSG_MC_DownloadMediaThumbnail = 6204
 *          param1: <0失败，详见错误码
 ****************************************************/
int MC_DownloadThumbnailByTime(UI_HANDLE hUser, const char *sDevId, const char *sFileName, const char *sStreamType, const char *sMessageType, int nChannel, int nStartTime, int nEndTime, int nWidth = 0, int nHeight = 0, Bool bTimePoint = FALSE, int nSeq = 0);

// MC_DownloadThumbnail异步返回，此函数可设置下载列表中的任务数量；默认为N_MAX_DOWNLOAD_QUEUE_SIZE
int MC_SetDownloadThumbnailMaxQueue(int nMaxQueueSize);

// 取消全部缩略图下载任务
void MC_StopDownloadThumbnail();

/*******************设备相关接口**************************
 * 方法名: 云存储视频时间轴查询
 * 描  述: 云存储视频时间轴查询（一天内）,最好查询一整天
 * 返回值:[无]
 * 参  数:
 *      输入(in)
 *          [sDevId:设备序列号]
 *          [sStreamType:主辅码流 "Main"]
 *          [nChannel:通道号]
 *          [nStartTime:开始时间]
 *          [nEndTime:结束时间]
 *      输出(out)
 *          [无]
 * 结果消息：
 *          消息id:EMSG_MC_SearchMediaTimeAxis = 6205, // 查询云视频时间轴（一天内）
 *          param1: <0失败，详见错误码
 *          Str:查询到的结果，json信息
 ****************************************************/
int MC_SearchMediaTimeAxis(UI_HANDLE hUser, const char *sDevId, const char *sStreamType, int nChannel, int nStartTime, int nEndTime, int nSeq = 0);
