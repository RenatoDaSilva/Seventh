unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer,
  IdHTTPServer, IdContext, Vcl.StdCtrls, Vcl.Buttons, IdSocketHandle,
  IdThread, IdIOHandler;

type
  TfrmMain = class(TForm)
    IdHTTPServerMain: TIdHTTPServer;
    mmLog: TMemo;
    edPort: TEdit;
    lbPort: TLabel;
    sbService: TSpeedButton;
    Label1: TLabel;
    procedure IdHTTPServerMainCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure sbServiceClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IdHTTPServerMainStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure IdHTTPServerMainAfterBind(Sender: TObject);
    procedure IdHTTPServerMainBeforeBind(AHandle: TIdSocketHandle);
    procedure IdHTTPServerMainCommandOther(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  private
    procedure SetSbServiceCaption;
    procedure DoLog(aLog: string);
    procedure IdHTTPServerMainCommand(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses uAPI;

procedure TfrmMain.sbServiceClick(Sender: TObject);
begin
  IdHTTPServerMain.DefaultPort := StrToIntDef(edPort.Text, 80);
  IdHTTPServerMain.Active := sbService.Down;
  SetSbServiceCaption;
end;

procedure TfrmMain.SetSbServiceCaption;
begin
  sbService.Caption := 'Iniciar Serviço';

  if sbService.Down then
    sbService.Caption := 'Parar Serviço';
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  SetSbServiceCaption;
end;

procedure TfrmMain.IdHTTPServerMainAfterBind(Sender: TObject);
begin
  DoLog('Serviço Inicializado');
end;

procedure TfrmMain.IdHTTPServerMainBeforeBind(AHandle: TIdSocketHandle);
begin
  DoLog('Inicializando Serviço...');
end;

procedure TfrmMain.IdHTTPServerMainCommandOther(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  IdHTTPServerMainCommand(AContext, ARequestInfo, AResponseInfo);
end;

procedure TfrmMain.IdHTTPServerMainCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  IdHTTPServerMainCommand(AContext, ARequestInfo, AResponseInfo);
end;

procedure TfrmMain.IdHTTPServerMainCommand(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  API: TAPI;
begin
  API := TAPI.Create;
  try
    API.Process(ARequestInfo);
    AResponseInfo.ContentType := 'application/json';
    AResponseInfo.ContentText := API.Response.JSON;
    AResponseInfo.ResponseNo := API.Response.Status;
  finally
    API.Free;
  end;
end;

procedure TfrmMain.IdHTTPServerMainStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin
  DoLog(AStatusText);
end;

procedure TfrmMain.DoLog(aLog: string);
begin
  mmLog.Lines.Append(Format('%s'#9'%s', [FormatDateTime('dd/mm/yyyy hh24:nn:ss', Now()), aLog]));
end;

end.
