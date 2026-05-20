// ============================================================
//  示范工程配置文件
//  修改此文件即可增删工程、修改域名/监控链接
// ============================================================

// --- 示范工程列表 ---
var PROJECTS = [
    { id: "p4", name: "通苏嘉甬苏州东隧道", location: "江苏苏州", lat: 31.3200, lng: 120.7200, investment: "11.81 km", progress: 75, status: "盾构掘进", provinceCode: 320000, cityCode: 320500 },
    { id: "p2", name: "扬州至仪征线市域铁路一/二/六期", location: "江苏扬州", lat: 32.3942, lng: 119.4129, investment: "14.38 km", progress: 65, status: "施工中", provinceCode: 320000, cityCode: 321000 },
    { id: "p6", name: "西渝高铁合川东隧道", location: "重庆合川", lat: 30.2625, lng: 106.2247, investment: "7.39 km", progress: 35, status: "施工中", provinceCode: 500000, cityCode: 500117 },
    { id: "p1", name: "上海合流污水一期复线FXZ1.3标", location: "上海市", lat: 31.2304, lng: 121.4737, investment: "4.83 km", progress: 88, status: "方案备案", provinceCode: 310000, cityCode: 310100 },
    { id: "p3", name: "温州茶白片区EUP竖井智慧车库", location: "浙江温州", lat: 27.9943, lng: 120.6994, investment: "深 65.92m", progress: 42, status: "基坑开挖", provinceCode: 330000, cityCode: 330300 },
    { id: "p5", name: "侨城东路北延地下立交示范工程", location: "广东深圳", lat: 22.5500, lng: 114.0500, investment: "57 m", progress: 90, status: "主体结构", provinceCode: 440000, cityCode: 440300 }
];

// --- 各工程监控平台链接 ---
var PROJECT_URLS = {
    p2: "http://120.55.70.218/md/nycj/",
    p4: "http://120.55.70.218/tsjy/"
};

// --- 帆软报表链接 (iframe 弹窗用) ---
var FINE_REPORT_URLS = {
};

var FINE_REPORT_URL_DEFAULT = "https://dv.tongji.edu.cn/decision/v10/entry/access/13d26456-f1d6-4a56-bcdd-f1cd328dc465?preview=true&page_number=1";
