/**
 * @brief 报警服务相关接口
 * @details 新的简化协议
 * @author baixu
 * @date 2023/03/09
 */

#ifndef __FUN_AS_H_
#define __FUN_AS_H_

#include "XTypes.h"

/**
 * @brief 报警服务初始化
 * @details 只需初始化一次，多次初始化会相互覆盖
 * @details  异步回调消息：id:6400 param1: >=0 成功，否者失败
 * @param szInitInfo 参数信息(JSON格式) 参考如下：
 * {
 *    "user" : "",  ///< 云账户用户名 Android内部推送使用
 *    "pwd" : "",   ///< 云账户密码 Android内部推送使用
 *    "language" : "", ///< 报警语言类型  *传空字符串的话SDK内部自动获取
 *    "tk" : "", ///< 报警推送服务使用的TOKEN  *只有Android客户端需要传此字段，用于XM内部报警推送服务
 *    "userid" :"" ///< 【可选】云账户UserID *如果需要通过UserId进行报警订阅，必须包含此字段，字段内容可以为空(SDK读取内部缓存)
 * }
 */
int AS_Init(UI_HANDLE hUser, const char *szInitInfo, int nSeq);

/**
 * @brief 报警订阅
 * @details 支持批量设备&&批量Token订阅
 * @details 异步回调消息：id:6401 param1: >=0 成功，否者失败 Str():订阅成功序列号集合
 * @param szReqJson 参数信息(JSON格式) 参考如下：
 * @example
 * {
 *    "msg" : "alarm_subscribe",
 *    "snlist" :
 *    [
 *      {
 *          "sn" : "",  ///< 设备序列号
 *          "dev" : "" ///< 【可选】 设备别名
 *      }
 *    ]
 *    "voclist" : "", ///< 【可选】ios新增声音标识
 *    "tklist" :
 *    [
 *      {
 *          "tk" : "",  ///< 报警订阅TOKEN
 *          "ty" : ""  ///< 报警订阅类型，可传第三方报警服务地址
 *      }
 *    ]
 * }
 */
int AS_DevsAlarmSubscribe(UI_HANDLE hUser, const char *szReqJson, int nSeq);

/**
 * @brief 取消报警订阅
 * @details 支持批量设备&&批量Token取消订阅
 * @details 异步回调消息：id:6402 param1: >=0 成功，否者失败 Str():取消订阅成功序列号集合
 * @param szReqJson 参数信息(JSON格式) 参考如下：
 * @example
 * {
 *    "msg" : "alarm_unsubscribe",
 *    "all": "0",                  ///<【可选】 0或者无该字段表示:只删除指定Token的订阅关系 1表示:删除该设备的所有订阅关系（此时不需要AppToken字段）,
 *                                              2表示: 只保留UserId对应的订阅关系  3表示: 只清除UserId对应的订阅关系
*     "ut": 123456,     ///<【可选】 utc时间，如果晚于这个时间订阅的才会删除，用于删除指定时间前的订阅（仅用于根据userid删除订阅情况）
 *    "snlist" :
 *    [
 *      {
 *          "sn" : "",  ///< 设备序列号
 *      }
 *    ]
 *    "tklist" :
 *    [
 *      {
 *          "tk" : "",  ///< 报警订阅TOKEN
 *      }
 *    ]
 * }
 */
int AS_DevsAlarmUnSubscribe(UI_HANDLE hUser, const char *szReqJson, int nSeq);

/**
 * @brief 报警订阅(UserID)
 * @details 通过UserID进行订阅，UserID && 批量Token订阅
 * @details 异步回调消息：id:6412 param1: >=0 成功，否者失败 Str():订阅成功序列号集合
 * @param szReqJson 参数信息(JSON格式) 参考如下：
 * @example
 * {
 *    "msg" : "userid_subscribe"(客服系统),  ///< userid_adv_subscribe（广告推送）
 *    "uslist" :  ///< 暂不支持多个。。userid数组只能传一个
 *    [
 *      {
 *          "userid" : "",
 *      }
 *    ]
 *    "tklist" :
 *    [
 *      {
 *          "tk" : "",  ///< 报警订阅TOKEN
 *          "ty" : ""  ///< 报警订阅类型
 *      }
 *    ]
 * }
 */
int AS_UserIDAlarmSubscribe(UI_HANDLE hUser, const char *szReqJson, int nSeq);

/**
 * @brief 取消报警订阅(UserID)
 * @details 通过UserID取消订阅，UserID && 批量Token订阅
 * @details 异步回调消息：id:6413 param1: >=0 成功，否者失败 Str():取消订阅成功序列号集合
 * @param szReqJson 参数信息(JSON格式) 参考如下：
 * @example
 * {
 *    "msg" : "userid_unsubscribe"(客服系统),  ///< userid_adv_unsubscribe（广告推送）
 *    "all": "1",                  //【可选】 //1表示:删除该userid的所有订阅关系（此时不需要tklist）
 *    "uslist" :
 *    [
 *      {
 *          "userid" : "",  ///< 设备序列号
 *      }
 *    ]
 *    "tklist" :
 *    [
 *      {
 *          "tk" : "",  ///< 报警订阅TOKEN
 *      }
 *    ]
 * }
 */
int AS_UserIDAlarmUnSubscribe(UI_HANDLE hUser, const char *szReqJson, int nSeq);

/**
 * @brief 查询报警消息列表
 * @details 最多查询200条，要查询全部请使用AS_QueryAlarmMsgListByTime接口
 * @details 异步回调消息：id:6403 param1: >=0 成功，否者失败 Str:设备序列号 pData：消息列表信息
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *   "msg": "alarm_query",
 *   "sn": "c142dd39f8222e1d",
 *   "am": "1",    ///<【可选】未携带此字段则不下发图片url，协议标识（用于标识客户端是否支持https，1 表示支持https下发的下载地址为https，0 表示不支持http下发的下载地址为http，其他将返回错误）
 *   "wd": "80",   ///<【可选】缩略图宽 整数字符串 未携带下发原图url
 *   "hg": "123",  ///<【可选】缩略图高 整数字符串 未携带下发原图url
 *   "ch": 0      ///<【可选】不填写此字段表示查询所有通道
 *   "pgsize":20, ///<【可选】单次分页查询个数，不传按原方案走，默认为20，可设置在1~20区间
 *   "pgnum":1,   ///<【可选】查询页数，从1开始，传1将重新刷新数据库，否者不会更新 默认1
 *   "event":"",  ///<【可选】查询报警类型
 *  }
 */
int AS_QueryAlarmMsgList(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 按时间查询报警消息列表
 * @details 接口内部自动循环查询，直到传递的时间范围内查不到结果
 * @details 异步回调消息：id:6404 param1: >=0 成功，否者失败 Str:设备序列号 pData：消息列表信息
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *   "msg": "alarm_query",
 *   "sn": "4ad15e3168fb9061",
 *   "am": "1",    ///<【可选】未携带此字段则不下发图片url，协议标识（用于标识客户端是否支持https，1 表示支持https下发的下载地址为https，0 表示不支持http下发的下载地址为http，其他将返回错误）
 *   "wd": "80",   ///<【可选】缩略图宽 整数字符串 未携带下发原图url
 *   "hg": "123",  ///<【可选】缩略图高 整数字符串 未携带下发原图url
 *   "ch": 0,      ///<【可选】不填写此字段表示查询所有通道
 *   "st" : "2017-11-29 07:03:58",
 *   "et" : "2017-11-29 07:04:58"
 *   "pgsize":20, ///<【可选】单次分页查询个数，不传按原方案走，默认为20，可设置在1~20区间
 *   "pgnum":1,   ///<【可选】查询页数，从1开始，传1将重新刷新数据库，否者不会更新 默认1
 *   "event":"",  ///<【可选】查询报警类型
 *  }
 */
int AS_QueryAlarmMsgListByTime(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
* @brief 报警消息图片下载
* @details 支持云端和普通报警消息图片下载，只支持单个报警消息图片下载
* @details 异步回调消息：id:6414 param1: >=0 成功，否者失败 Str:图片存储地址
* @param szReqJson 请求信息(JSON格式)，参考如下：
* @example
* {
*   "msg": "download_alarm_image",
*   "sn": "4ad15e3168fb9061",
*   "filename": "", ///< 文件存储绝对路径
 *  "downloadbyurl" : "0", ///< 是否通过url下载图片，"1"：通过url直接下载图片，alarmmsg需要包含picinfo/url字段 "0":通过其他信息下载图片
*   "wd": "80",   ///<【可选】缩略图宽 整数字符串 未携带下载原图
*   "hg": "80",  ///<【可选】缩略图高 整数字符串 未携带下载原图
*   "alarminfo": ///< 报警信息，查询返回的数据，只支持单个报警消息图片下载
*   {
*       ...
*   },
*  }
*/
int AS_DownloadAlarmMsgImage(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 取消等待队列中所有未下载的图片
 * @details 正在下载中的无法取消
 * @details 异步回调消息：id:6415 param1: >=0 成功，否者失败
 */
int AS_StopDownloadAlarmMsgImage(UI_HANDLE hUser, int nSeq = 0);

/**
 * @brief 是否有报警消息产生
 * @details 获取某个指定时间之后的报警个数，用于APP显示未读或者新增消息的个数
 * @details 异步回调消息：id:6405 param1: >=0 成功，否者失败 Str:结果信息 pData:查询成功的序列号集合
 * @example
 * {
 *   "msg": "nmq", ///< new message query
 *   "time": "2022-07-12 20:03:06", ///< 【可选】从当前time开始是否有新的报警消息（当多个设备查一个时间点时使用该字段）,此字段存在优先使用此字段
 *   "snlist":
 *   [
 *     {
 *        "sn": "xxx",
 *        "time": "2022-07-12 20:03:06", ///< 【可选】从当前time开始是否有新的报警消息（当多个设备查不同时间点时使用该字段）
 *     }
 *   ]
 * }
 */
int AS_WhetherAnAlarmMsgIsGenerated(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 根据时间点查询云视频片段信息
 * @details 批量根据时间点查询视频片段信息，单次最多查询50个，超过50个取前50个，少于50按实际的查找，仅返回查找到的信息
 * @details 异步回调消息：id:6406 param1: >=0 成功，否者失败 Str:结果信息
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *  "msg": "video_clip", 或者 "msg": "short_video_clip"  ///< 查看短视频的请求
 *  "sn": "xx", ///< 设备序列号
 * 	"ch": 0, ///< 【可选】不填写此字段表示查询所有通道
 * 	"time":[ "2023-02-28 17:00:00","2023-02-28 18:00:00","2023-02-28 19:00:00"....], ///< 报警时间点
 * }
 */
int AS_QueryCloudVideoClipInfoByPoint(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 日历功能
 * @details 按时间查询日历，可查看视频节点和报警消息节点
 * @details 异步回调消息：id:6407 param1: >=0 成功，否者失败 Str:结果信息
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *  "msg": "alendar",
 *  "sn": "c142dd39f8222e1d", ///< 设备序列号
 *  "dt": "2017-11",  ///< 按月查询，如果按天查询则Data对应的value为json数组，例："dt": [{"tm": "2017-11-01"},{"tm": "2017-11-02"}]  如果支持最新一条消息 Date：Last
 *  "ty": "VIDEO",  ///< VIDEO：查询视频日历节点 MSG：查询报警消息日历节点
 * 	"ch": 0 ///< 【可选】不填写此字段表示查询所有通道
 * }
 */
int AS_QueryCalendarByTime(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 删除报警信息
 * @details 删除报警信息
 * @details 异步回调消息：id:6408 param1: >=0 成功，否者失败 Str:结果信息
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *	"msg": "alarm_delete",
 *	"sn": "14005d42a45417d7",
 *	"delty": "MSG",          ///< 删除消息和图片为:MSG  删除视频:VIDEO
 *	"ids": [ --【可选】 如果没有ids会全部清空
 *	         {
 *				"id":"180905114640"
 *			 }
 *		   ]
 * }
 */
int AS_DeleteAlarm(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 查询订阅状态
 * @details 异步回调消息：id:6408 param1: >=0 成功，否者失败 Str:结果信息
 * @param szReqJson 请求信息(JSON格式)，参考如下：
 * @example
 * {
 *	 "msg": "query_subscribe",
 *	 "tks": ["token1", "token2"], ///< 根据token查询   *subty和tks同时存在，优先使用subty
 *	 "subty": "Android"       ///< 根据设备类型查询，subty目前包括: Android Hook IOS Google XG HuaWei Third  ALL(表示查询所有订阅类型)
 *	 "snlist": [{
 *		 "sn": "c142dd39f8222e1a"
 *	 }]
 * }
 */
int AS_QuerySubscribeStatus(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 查询状态历史记录
 * @details 访问的服务器并不是pms服务，暂时放在一块。。
 * @details 异步回调消息：id：6410; param1: >=0 成功，否者失败; Str()：结果信息(Json格式，数据内容APP需重新按时间排序) pData:查询成功的设备序列号集合
 * @example
 * {
 *   "msg": "status_history",
 *	 "sort": "asc", ///< 升序排列  降序使用"desc"
 *	 "count" : 200, ///< 查询条数，默认500，最多500（因为设备可能分配在不同的服务器，实际客户端收到的的最大条数是500的成倍增加）
 *	 "startTm": 1664001721, ///< utc时间，默认0   *批量设备只能查询同一个时间范围
 *	 "endTm": 1664001721, ///< utc时间，默认当前时间
 *	 "snlist": [{
 *		 "sn": "027995bbc8d649901b"
 *	 }]
 * }
 */
int AS_QueryStatusHistoryRecord(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 查询云视频播放地址
 * @details 访问的服务器并不是pms服务，暂时放在一块。。返回的内容组成：http://host:6614/css_hls/VideoName
 * @details 异步回调消息：id：6411; param1: >=0 成功，否者失败; Str()：结果信息(Json格式)
 * @example
 * {
 *   "msg": "query_hls_url",
 *	 "sn": "xxxx",
 *	 "ch": 0,      ///<【可选】不填写此字段表示查询所有通道
 *	 "last" : "1",   ///< 【可选】如果有此字段，则表示更新最新的m3u8文件
 *   "st" : "2017-11-29 07:03:58",
 *   "et" : "2017-11-29 07:04:58",
 * }
 */
int AS_QueryCloudVideoHlsUrl(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

/**
 * @brief 设置报警消息已读标志
 * @param szDevSN 设备序列号
 * @param szAlarmIDs 报警消息ID，多个以";"分隔，为NULL或空字符串，表示设置全部报警消息已读
 * @details 异步回调消息：id:6416 param1: >=0 成功，否者失败
 * @example
 * {
 *  "msg": "msgstatus_record", ///< 接口标识
 *  "sn": "xxxxxxxxx",         ///< 设备序列号
 *  "ids": ["","",""]          ///< alarmid列表
 * }
 */
int AS_SetAlarmMsgReadFlag(UI_HANDLE hUser, const char *szReqJson, int nSeq = 0);

#endif //__FUN_AS_H_