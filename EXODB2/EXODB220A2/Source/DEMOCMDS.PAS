unit DemoCmds;

{$D-}

{0-99 , 256-999}

interface

const
  cmAbout           = 1002;
  cmPuzzle          = 1003;
  cmCalendar        = 1004;
  cmAsciiTab        = 1005;
  cmCalculator      = 1006;
  cmMouse           = 1007;
  cmColors          = 1008;
  cmSaveDesktop     = 1010;
  cmRetrieveDesktop = 1011;
  cmShowClip        = 1012;

  cmMoreObjects     = 3000;
  cmCredits         = 3001;
  cmThanks          = 3002;
  cmOrbit           = 3003;
  cmOrbitAbort      = 3004;
  cmSearch          = 3005;
  cmSearchAbort     = 3006;
  cmFilter          = 3007;
  cmFilterAbort     = 3008;
  cmRecords         = 3009;
  cmPlanetStatus    = 3010;
  cmDiagram         = 3011;
  cmDiagramAbort    = 3012;
  cmDistribution    = 3013;
  cmDistributionAbort = 3014;
  cmStar3D          = 3015;
  cmStar3DAbort     = 3016;
  cmStarmap         = 3017;
  cmStarmapAbort    = 3018;
  cmMassCompare     = 3019;
  cmMassCompareAbort = 3020;
  cmHRD             = 3021;
  cmHRDAbort        = 3022;
  cmStarTypeOK      = 3023;
  cmStarTypeAbort   = 3024;
  cmDustdisc        = 3025;
  cmDustDiscOK      = 3026;
  cmDustDiscAbort   = 3027;
  cmDiscoverMethodOK = 3028;
  cmDiscoverMethodAbort = 3029;
  cmDiscoverStatusOK = 3030;
  cmDiscoverStatusAbort = 3031;
  cmObjectListOK    = 3032;
  cmObjectListAbort = 3033;

  cmDBStartype      = 3100;
  cmDBBegin         = 3101;
  cmDBminus10       = 3102;
  cmDBminus1        = 3103;
  cmDBplus10        = 3104;
  cmDBplus1         = 3105;
  cmDBEnd           = 3106;
  cmDBStarlistBack  = 3107;
  cmDBStarlistForward = 3108;
  cmDBStarmassNil   = 3109;
  cmDBStarradiusNil = 3110;
  cmDBLuminosityNil = 3111;
  cmDBAgeNil        = 3112;
  cmDBDistanceNil   = 3113;
  cmDBMetalicityNil = 3114;
  cmDBStarRVNil     = 3115;
  cmDBMagVisNil     = 3116;
  cmDBMagAbsNil     = 3117;
  cmDBStarAxisNil   = 3118;
  cmDBStarEccNil    = 3119;
  cmDBDustdisc      = 3120;
  cmDBStarList      = 3121;
  cmDBPlanetList    = 3122;
  cmDBPlanetListBack = 3123;
  cmDBPlanetListForward = 3124;
  cmDBPlanetmassNil = 3125;
  cmDBPlanetradiusNil = 3126;
  cmDBPlanetAxisNil = 3127;
  cmDBPlanetEccNil  = 3128;
  cmDBInclinationNil = 3129;
  cmDBTPeriNil      = 3130;
  cmDBOmegaNil      = 3131;
  cmDBPlanetRVNil   = 3132;
  cmDBPlanetDisMethod = 3133;
  cmDBPlanetDisStatus = 3134;
  cmDBmenu          = 3135;
  cmDBEraseYes      = 3201;
  cmDBEraseNo       = 3202;
  cmDBExport        = 3203;
  cmDBExportAbort   = 3204;
  cmDBRename        = 3205;
  cmDBRenameAbort   = 3206;
  cmDBSetExport     = 3207;
  cmDBSetExportAbort= 3208;
  cmDBSetEraseYes   = 3209;
  cmDBSetEraseNo    = 3210;
  cmDBObjectExport  = 3211;
  cmDBObjectExportAbort = 3212;
  cmDBObjectEraseYes= 3213;
  cmDBObjectEraseNo = 3214;



  slNil            =  200;

  slDB             = 1000;
  slDBCreate       = 1010;
  slDBCreateManual = 1011;
  slDBCreateRandom = 1012;
  slDBOpen         = 1020;
  slDBRename       = 1030;
  slDBExport       = 1040;
  slDBErase        = 1050;
  slDBSet          = 1060;
  slDBSetAdd       = 1061;
  slDBSetChange    = 1062;
  slDBSetExport    = 1063;
  slDBSetErase     = 1064;
  slDBObjectAdd    = 1061;
  slDBObjectChange = 1062;
  slDBObjectExport = 1063;
  slDBObjectErase  = 1064;
  slModule         = 1100;
  slModuleRecords  = 1101;
  slModuleStatus   = 1102;
  slModuleSysHierarchie = 1103;
  slModuleOrbit    = 1104;
  slModuleMass     = 1105;
  slModuleStarmap  = 1106;
  slModuleDistri   = 1107;
  slModuleDiagram  = 1108;
  slModuleHRD      = 1109;
  slModuleStar3D   = 1110;
  slOption         = 1200;
  slOptionFind     = 1201;
  slOptionFilter   = 1202;
  slOptionConfig   = 1203;
  slOptionColor    = 1204;
  slOptionMouse    = 1205;
  slOptionDesktopSave = 1206;
  slOptionDesktopRetrieve = 1207;
  slMisc           = 1300;
  slMiscInfo       = 1301;
  slMiscCredits    = 1302;
  slMiscThanks     = 1303;
  slMiscHelp       = 1304;
  slMiscCalendar   = 1305;
  slMiscCalculator = 1306;
  slMiscPuzzle     = 1307;
  slMiscAsciiTab   = 1308;
  slWindow         = 1400;
  slMenu           = 1500;

implementation

end.
