unit uRecycler;

interface

uses
  Classes, Windows, uPersist;

type
  TRecycler = class(TThread)
  private
    FDays: integer;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    property Days: integer read FDays write FDays;
  end;

implementation

constructor TRecycler.Create;
begin
   inherited Create(True);
end;

destructor TRecycler.Destroy;
begin
  inherited;
end;

procedure TRecycler.Execute;
begin
  Synchronize(procedure
              var
                Persist: TPersist;
              begin
                Persist := TPersist.Create(nil);
                try
                  Persist.RecycleVideos(FDays);
                finally
                  Persist.Free;
                end;
              end);
end;

end.
