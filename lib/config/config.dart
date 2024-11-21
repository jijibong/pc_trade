class Config {
  ///请求地址
  static String AppUpdateURL = "http://svr.mgt.yhrjkj.com:20190"; //app版本更新地址
  static String URL = "https://api.dfyruanjian.com"; //本地测试地址
//   static String MdURL = "https://quote.xydruanjian.com:60000";//行情服务器地址
  static String MdURL = "http://gj.market.yhrjkj.com:60001"; //行情服务器地址
  static String WebScoketUrl = "ws://113.31.110.14:7001/";
  static int TradePort = 6003;
  static String Token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NSwicm9sZSI6NCwicHQiOjMsIlVVSUQiOiIiLCJpYXQiOjE1NDUzODQ0MzUsImlzcyI6Imp1ZGFzaGkifQ.IaXEsokKKYTZJGlDIciksvWPsG6acyGJQFTmcRhHPEg";

  /// 获取验证码编号
  static String vcodeIdUrl = "/v1/verifycode/new";

  ///获取验证码图片
  static String vcodeImgUrl = "/v1/verifycode/get/";

  ///登录
  static String loginUrl = "/v1/user/login";

  ///登出
  static String loginOutUrl = "/v1/user/loginout";

  ///查询交易所
  static String queryExchangeUrl = "/v1/user/all/exchange";

  ///查询交易所下的合约
  static String queryContractUrl = "/v1/user/exchange/contract";

  ///查询全部合约
  static String queryAllContractUrl = "/v1/user/all/contract";

  ///添加自选
  static String addOption = "/v1/user/option/add";

  ///批量添加自选
  static String addManyOption = "/v1/user/option/add/many";

  ///删除自选
  static String delOption = "/v1/user/option/del";

  ///查询自选
  static String queryOption = "/v1/user/option/query";

  ///自选排序
  static String orderOption = "/v1/user/option/sort";

  ///查询分时
  static String queryFs = "/v1/kline/time";

  ///查询K线
  static String queryKline = "/v1/kline/data";

  ///添加搜索次数
  static String addSearchCount = "/v1/user/search/add/count";

  ///查询热门合约
  static String queryHot = "/v1/user/search/hot";

  ///添加历史搜索
  static String addSearchHis = "/v1/user/search/add";

  ///查询历史搜索
  static String querySearchHis = "/v1/user/search/query";

  ///清空历史搜索
  static String clearSearchHis = "/v1/user/search/clear";

  ///获取资金账户信息
  static String getAccountFund = "/v1/fee/fund/query";

  ///获取账户信息
  static String getAccountInfo = "/v1/fengruan/trade/accountinfo";

  ///获取结算资金信息
  static String getSettleFund = "/v1/fee/fund/statemen";

  ///下单
  static String addOrder = "/v1/order/new";

  ///反手
  static String reverseOrder = "/v1/order/reverse";

  ///锁仓
  static String lockOrder = "/v1/order/lock";

  ///撤单
  static String cancleOrder = "/v1/order/cancel";

  ///查询撤单记录
  static String queryCancle = "/v1/order/today/cancel";

  ///查询持仓
  static String queryPosition = "/v1/order/user/position";

  ///查询历史持仓
  static String queryHisPosition = "/v1/order/history/position";

  ///查询汇率
  static String queryCurrent = "/v1/fengruan/trade/currentrate";

  ///设置止盈止损
  static String setPL = "/v1/order/set/stopWinLoss";

  ///查询止盈止损记录
  static String queryPL = "/v1/order/query/stopWinLoss";

  ///打开关闭止盈止损记录
  static String enablePL = "/v1/order/modify/stopWinLoss";

  ///修改止盈止损记录
  static String modifyPL = "/v1/order/mod/stopWinLoss";

  ///删除止盈止损记录
  static String delPL = "/v1/order/del/stopWinLoss";

  ///查询委托记录
  static String queryDelOrder = "/v1/order/today/order";

  ///查询历史委托记录
  static String queryHisDelOrder = "/v1/order/history/order";

  ///查询成交记录
  static String queryComOrder = "/v1/order/today/fill";

  ///查询历史成交记录
  static String queryHisComOrder = "/v1/order/history/fill";

  ///查询平仓明细
  static String queryCloseDetail = "/v1/order/history/close";

  ///查询当日条件单
  static String queryTodayCondition = "/v1/order/condition/qry";

  ///添加条件单
  static String addCondition = "/v1/order/condition/add";

  ///更新条件单
  static String updateCondition = "/v1/order/condition/update";

  ///删除条件单
  static String delCondition = "/v1/order/condition/del";

  ///查询码表更新时间
  static String queryCodeUpdateTime = "/v1/user/updatetime";

  ///查询数据分析数据
  static String queryAnalysisData = "/v1/analysis/dataAnalysis/analysis";

  ///查询数据分析资产
  static String queryAnalysisHis = "/v1/analysis/dataAnalysis/assetChange";

  ///查询合约初始保证金
  static String queryContractMargin = "/v1/user/contract/margin";

  ///查询用户消息
  static String queryUserMsg = "/v1/user/msg/query";

  ///查询用户消息的订单状态
  static String queryMsgOrderState = "/v1/user/msg/orderstatus";

  ///查询优先平今品种
  static String queryCloseToday = "/v1/user/commodity/closetoday";

  ///查询版本信息
  static String queryVersion = "/v1/software/get/update";

  ///查询使用环境
  static String queryEnvironmental = "/v1/environmental/get/getEnvironmental";

  ///查询交易服务商信息
  static String queryBroker = "/v1/environmental/get/brokerinfo/v1";

  ///自定义K线
  static String customKline = "/v1/kline/custom";

  ///查询公网ip
  static String queryIpAddress = "/v1/software/get/ipinfo";

  ///查询行情地址
  static String queryQuoteAddress = "/v1/software/qry/quoteaddr";

  ///结算单
  static String GET_CAPITAL = "/v1/report/reportForm/capital";

  ///平仓明细
  static String CLOSEDETAILED = "/v1/report/reportForm/closeDetailed";

  ///成交记录
  static String FILLRECORD = "/v1/report/reportForm/fillRecord";

  ///持仓明细
  static String POSITIONDETAILED = "/v1/report/reportForm/positionDetailed";

  ///出入金记录
  static String GET_CASHREPORT = "/v1/report/reportForm/cashReport";

  ///持仓汇总
  static String POSITIONSUMMARY = "/v1/report/reportForm/positionSummary";
}
