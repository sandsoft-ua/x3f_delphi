{********************************************************}
{*                  X3F Delphi Project                  *}
{*    Sigma RAW files to DNG, TIFF, JPEG conversion     *}
{*      Based on C sources from project Kalpanika       *}
{*           (https://github.com/Kalpanika)             *}
{*      Copyright SANDSoft Virtual Firm (c) 2018        *}
{*                                                      *}
{*      Last sources can be found at:                   *}
{*      https://github.com/sandsoft-ua/x3f_delphi       *}
{********************************************************}

unit x3f_io;

interface

const
  SIZE_UNIQUE_IDENTIFIER        = 16;
  SIZE_WHITE_BALANCE            = 32;
  SIZE_COLOR_MODE               = 32;
  NUM_EXT_DATA_2_1              = 32;
  NUM_EXT_DATA_3_0              = 64;
  NUM_EXT_DATA                  = NUM_EXT_DATA_3_0;
//#define X3F_VERSION(MAJ,MIN) (uint32_t)(((MAJ)<<16) + MIN)
  X3F_VERSION_2_0               = Cardinal(2 shl 16 + 0);
  X3F_VERSION_2_1               = Cardinal(2 shl 16 + 1);
  X3F_VERSION_2_2               = Cardinal(2 shl 16 + 2);
  X3F_VERSION_2_3               = Cardinal(2 shl 16 + 3);
  X3F_VERSION_3_0               = Cardinal(3 shl 16 + 0);
  X3F_VERSION_4_0               = Cardinal(4 shl 16 + 0);
  X3F_VERSION_4_1               = Cardinal(4 shl 16 + 1);
//
  X3F_FOVb                      = Cardinal($62564f46);
  X3F_SECd                      = Cardinal($64434553);
  X3F_PROP                      = Cardinal($504f5250);
  X3F_SECp                      = Cardinal($70434553);
  X3F_IMAG                      = Cardinal($46414d49);
  X3F_IMA2                      = Cardinal($32414d49);
  X3F_SECi                      = Cardinal($69434553);
  X3F_CAMF                      = Cardinal($464d4143);
  X3F_SECc                      = Cardinal($63434553);
  X3F_CMbP                      = Cardinal($50624d43);
  X3F_CMbT                      = Cardinal($54624d43);
  X3F_CMbM                      = Cardinal($4d624d43);
  X3F_CMb                       = Cardinal($00624d43);
  X3F_SPPA                      = Cardinal($41505053);
  X3F_SECs                      = Cardinal($73434553);
  X3F_IMAGE_THUMB_PLAIN         = Cardinal($00020003);
  X3F_IMAGE_THUMB_HUFFMAN       = Cardinal($0002000b);
  X3F_IMAGE_THUMB_JPEG          = Cardinal($00020012);
  X3F_IMAGE_THUMB_SDQ           = Cardinal($00020019) { SDQ ? - TODO };
  X3F_IMAGE_RAW_HUFFMAN_X530    = Cardinal($00030005);
  X3F_IMAGE_RAW_HUFFMAN_10BIT   = Cardinal($00030006);
  X3F_IMAGE_RAW_TRUE            = Cardinal($0003001e);
  X3F_IMAGE_RAW_MERRILL         = Cardinal($0001001e);
  X3F_IMAGE_RAW_QUATTRO         = Cardinal($00010023);
  X3F_IMAGE_RAW_SDQ             = Cardinal($00010025);
  X3F_IMAGE_RAW_SDQH            = Cardinal($00010027);
  X3F_IMAGE_HEADER_SIZE         = 28;
  X3F_CAMF_HEADER_SIZE          = 28;
  X3F_PROPERTY_LIST_HEADER_SIZE = 24;
  X3F_CAMERAID_DP1M             = 77;
  X3F_CAMERAID_DP2M             = 78;
  X3F_CAMERAID_DP3M             = 78;
  X3F_CAMERAID_DP0Q             = 83;
  X3F_CAMERAID_DP1Q             = 80;
  X3F_CAMERAID_DP2Q             = 81;
  X3F_CAMERAID_DP3Q             = 82;
  X3F_CAMERAID_SDQ              = 40;
  X3F_CAMERAID_SDQH             = 41;
  UNDEFINED_LEAF                = $ffffffff;
  TRUE_PLANES                   = 3;

  legacy_offset: Integer = 0;
  auto_legacy_offset: Boolean = True;

type
  x3f_extended_types_t = (
    X3F_EXT_TYPE_NONE              =  0,
    X3F_EXT_TYPE_EXPOSURE_ADJUST   =  1,
    X3F_EXT_TYPE_CONTRAST_ADJUST   =  2,
    X3F_EXT_TYPE_SHADOW_ADJUST     =  3,
    X3F_EXT_TYPE_HIGHLIGHT_ADJUST  =  4,
    X3F_EXT_TYPE_SATURATION_ADJUST =  5,
    X3F_EXT_TYPE_SHARPNESS_ADJUST  =  6,
    X3F_EXT_TYPE_RED_ADJUST        =  7,
    X3F_EXT_TYPE_GREEN_ADJUST      =  8,
    X3F_EXT_TYPE_BLUE_ADJUST       =  9,
    X3F_EXT_TYPE_FILL_LIGHT_ADJUST = 10);

  matrix_type = (
    M_FLOAT = 0,
    M_INT   = 1,
    M_UINT  = 2);

  x3f_return = (
    X3F_OK             = 0,
    X3F_ARGUMENT_ERROR = 1,
    X3F_INFILE_ERROR   = 2,
    X3F_OUTFILE_ERROR  = 3,
    X3F_INTERNAL_ERROR = 4);


  x3f_property = record
    name_offset,
    value_offset : uint32;
    name,
    value        : PWideChar; //^utf16_t; ???
    name_utf8,
    value_utf8   : PChar;
  end;
  Px3f_property = ^x3f_property;

  x3f_property_table = record
    size : uint32;
    element : Px3f_property;
  end;
  Px3f_property_table = ^x3f_property_table;

  x3f_property_list = record
    num_properties,
    character_format,
    reserved,
    total_length     : uint32;
    property_table   : x3f_property_table;
    data             : pointer;
    data_size        : uint32;
  end;
  Px3f_property_list = ^x3f_property_list;

  x3f_table8 = record
    size : uint32;
    element : ^byte;
  end;

  x3f_table16 = record
    size : uint32;
    element : PWord;
  end;

  x3f_table32 = record
    size : Cardinal;
    element : PCardinal;
  end;

  Px3f_huffnode = ^x3f_huffnode;
  x3f_huffnode = record
    branch: array[0..1] of Px3f_huffnode;
    leaf: Cardinal;
  end;

  x3f_true_huffman_element = record
    code_size,
    code      : byte;
  end;
  Px3f_true_huffman_element = ^x3f_true_huffman_element;

  x3f_true_huffman_table = record
  var
    size : Cardinal;
    element : Px3f_true_huffman_element;
  end;
  Px3f_true_huffman_table = ^x3f_true_huffman_table;

  x3f_hufftree = record
    free_node_index: Cardinal;   //* Free node index in huffman tree array */
    nodes: Px3f_huffnode;      //* Coding tree */
  end;
  Px3f_hufftree = ^x3f_hufftree;

  x3f_area16 = record
    data: System.PWord;		    //* Pointer to actual image data */
    buf: Pointer;			  //* Pointer to allocated buffer for free() */
    rows: uint32;
    columns: uint32;
    channels: uint32;
    row_stride: uint32;
  end;
  Px3f_area16 = ^x3f_area16;

  plane = array[0..TRUE_PLANES - 1] of Pbyte;
  Pplane = ^plane;

  x3f_true_t = record
    seed          : array[0..TRUE_PLANES-1] of Word;
    unknown       : Word;
    table         : x3f_true_huffman_table;
    plane_size    : x3f_table32;
    plane_address : plane;
    tree          : x3f_hufftree;
    x3rgb16       : x3f_area16;
  end;
  Px3f_true_t = ^x3f_true_t;


  x3f_quattro = record
    plane: array[0..TRUE_PLANES - 1] of record
      columns,
      rows           : Word;
    end;
    unknown        : Cardinal;
    quattro_layout : Boolean;
    top16          : x3f_area16;
  end;
  Px3f_quattro = ^x3f_quattro;

  x3f_area8 = record
    data: PByte;		    //* Pointer to actual image data */
    buf: Pointer;			  //* Pointer to allocated buffer for free() */
    rows: uint32;
    columns: uint32;
    channels: uint32;
    row_stride: uint32;
  end;

  x3f_huffman = record
    mapping     : x3f_table16;
    table       : x3f_table32;
    tree        : x3f_hufftree;
    row_offsets : x3f_table32;
    rgb8        : x3f_area8;
    x3rgb16     : x3f_area16;
  end;
  Px3f_huffman = ^x3f_huffman;

  x3f_image_data = record
    &type,
    format,
    type_format,
    columns,
    rows,
    row_stride  : uint32;
    huffman     : Px3f_huffman;
    tru         : Px3f_true_t;
    quattro     : Px3f_quattro;
    data        : pointer;
    data_size   : uint32;
  end;
  Px3f_image_data = ^x3f_image_data;

  camf_dim_entry = record
    size,
    name_offset,
    n           : uint32;
    name        : PAnsiChar;
  end;
  Pcamf_dim_entry = ^camf_dim_entry;

  camf_entry = record
    entry                         : pointer;
    id,
    version,
    entry_size,
    name_offset,
    value_offset                  : uint32;
    name_address                  : PAnsiChar;
    value_address                 : pointer;
    name_size,
    value_size,
    text_size                     : uint32;
    text                          : PAnsiChar;
    property_num                  : uint32;
    property_name,
    property_value                : ^PByte;
    matrix_dim                    : uint32;
    matrix_dim_entry              : Pcamf_dim_entry;
    matrix_type,
    matrix_data_off               : uint32;
    matrix_data                   : pointer;
    matrix_element_size           : uint32;
    matrix_decoded_type           : matrix_type;
    matrix_decoded                : pointer;
    matrix_elements,
    matrix_used_space             : uint32;
    matrix_estimated_element_size : Double;
  end;
  Pcamf_entry = ^camf_entry;

  camf_entry_table = record
    size : uint32;
    element : Pcamf_entry;
  end;

  x3f_camf_typeN = record
    val0, val1, val2, val3 : uint32;
  end;

  x3f_camf_type2 = record
    reserved,
    infotype,
    infotype_version,
    crypt_key        : uint32;
  end;

  x3f_camf_type4 = record
    decoded_data_size,
    decode_bias,
    block_size,
    block_count       : uint32;
  end;

  x3f_camf_type5 = record
    decoded_data_size,
    decode_bias,
    unknown2,
    unknown3          : uint32;
  end;

  x3f_camf_t = record
    &type             : uint32;
    tN                : x3f_camf_typeN;
    t2                : x3f_camf_type2;
    t4                : x3f_camf_type4;
    t5                : x3f_camf_type5;
    data              : pointer;
    data_size         : uint32;
    table             : x3f_true_huffman_table;
    tree              : x3f_hufftree;
    decoding_start    : PByte;
    decoding_size     : uint32;
    decoded_data      : pointer;
    decoded_data_size : uint32;
    entry_table       : camf_entry_table;
  end;
  Px3f_camf_t = ^x3f_camf_t;

  x3f_directory_entry_header = record
    identifier,
    version       : uint32;
    data_subsection: record
      case Integer of
      0: (property_list : x3f_property_list);
      1: (image_data    : x3f_image_data);
      2: (camf          : x3f_camf_t);
    end;
  end;
  Px3f_directory_entry_header = ^x3f_directory_entry_header;

  x3f_directory_entry = record
    input, output: record
      offset,
      size: uint32;
    end;
    &type : uint32;
    header : x3f_directory_entry_header;
  end;
  Px3f_directory_entry = ^x3f_directory_entry;

  x3f_directory_section = record
  var
    identifier,
    version,
    num_directory_entries : uint32;
    directory_entry       : Px3f_directory_entry;
  end;
  Px3f_directory_section = ^x3f_directory_section;

  x3f_header = record
  var
    identifier,
    version           : uint32;
    unique_identifier : array[0..(SIZE_UNIQUE_IDENTIFIER)-1] of byte;
    mark_bits,
    columns,
    rows,
    rotation          : uint32;
    white_balance     : array[0..(SIZE_WHITE_BALANCE)-1] of byte;
    color_mode        : array[0..(SIZE_COLOR_MODE)-1] of byte;
    extended_types    : array[0..(NUM_EXT_DATA)-1] of byte;
    extended_data     : array[0..(NUM_EXT_DATA)-1] of Single;
  end;

  x3f_info = record
  var
    error : String;
    in_file : Integer;
    out_file : Integer;
  end;
  Px3f_info = ^x3f_info;

  x3f = record
    info              : x3f_info;
    header            : x3f_header;
    directory_section : x3f_directory_section;
  end;
  Px3f = ^x3f;

function x3f_new_from_file(in_file: Integer): Px3f;
function x3f_load_data(_x3f: Px3f; DE: Px3f_directory_entry): x3f_return;
function x3f_get_camf(_x3f: Px3f): Px3f_directory_entry;
function x3f_get_raw(_x3f: Px3f): Px3f_directory_entry;

implementation

uses
  Windows, SysUtils;

const
  HUF_TREE_MAX_LENGTH = 27;

function HUF_TREE_MAX_NODES(_leaves: Integer): Integer; inline;
begin
  Result := (HUF_TREE_MAX_LENGTH + 1) * (_leaves)
end;

//* --------------------------------------------------------------------- */
//* Getting a reference to a directory entry                              */
//* --------------------------------------------------------------------- */

//* TODO: all those only get the first instance */

function x3f_get(_x3f: Px3f; &type: uint32; image_type: uint32): Px3f_directory_entry;
var
  DS: Px3f_directory_section;
  DE: Px3f_directory_entry;
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
  d: Integer;
begin
  Result := nil;

  if Assigned(_x3f) then
  begin
    DS := @(_x3f.directory_section);
    DE := DS.directory_entry;

    for d := 0 to DS.num_directory_entries - 1 do
    begin
      DEH := @(DE.header);

      if DEH.identifier = &type then
      begin
        case DEH.identifier of
        X3F_SECi:
          begin
            ID := @(DEH.data_subsection.image_data);

            if ID.type_format = image_type then
              Result := DE;
          end;
        else
          Result := DE;
        end;

        if Assigned(Result) then
          break;
      end;

      Inc(DE);  //Increment pointer
    end;
  end;
end;

function x3f_get_raw(_x3f: Px3f): Px3f_directory_entry;
begin
  Result := nil;

  Result := x3f_get(_x3f, X3F_SECi, X3F_IMAGE_RAW_HUFFMAN_X530);

  if not Assigned(Result) then
  begin
    Result := x3f_get(_x3f, X3F_SECi, X3F_IMAGE_RAW_HUFFMAN_10BIT);

    if not Assigned(Result) then
    begin
      Result := x3f_get(_x3f, X3F_SECi, X3F_IMAGE_RAW_TRUE);

      if not Assigned(Result) then
      begin
        Result := x3f_get(_x3f, X3F_SECi, X3F_IMAGE_RAW_MERRILL);

        if not Assigned(Result) then
        begin
          Result := x3f_get(_x3f, X3F_SECi, X3F_IMAGE_RAW_QUATTRO);

          if not Assigned(Result) then
          begin
            Result := x3f_get(_x3f, X3F_SECi, X3F_IMAGE_RAW_SDQ);

            if not Assigned(Result) then
              Result := x3f_get(_x3f, X3F_SECi, X3F_IMAGE_RAW_SDQH);
          end;
        end;
      end;
    end;
  end;
end;

//* --------------------------------------------------------------------- */
//* Reading and writing - assuming little endian in the file              */
//* --------------------------------------------------------------------- */

function x3f_get1(f: THandle): Integer; inline;
begin
  //* Little endian file */
  Result := 0;
  FileRead(f, Result, 1);
end;

function x3f_get2(f: THandle): Integer; inline;
var
  _tmp: Integer;
begin
  //* Little endian file */
  _tmp := x3f_get1(f);
  Result := 0;
  FileRead(f, Result, 1);
  Result := _tmp + (Result shl 8);
end;

function x3f_get4(f: THandle): Integer;
var
  _tmp: Integer;
begin
  //* Little endian file */
  _tmp := x3f_get2(f);
  Result := 0;
  FileRead(f, Result, 1);
  _tmp := _tmp + (Result shl 16);
  Result := 0;
  FileRead(f, Result, 1);
  Result := _tmp + (Result shl 24);
end;

function x3f_get4f(f: THandle): Single;
var
  _tmp: record
    case Integer of
    0: (i: Integer);
    1: (f: Single);
  end;
begin
  _tmp.i := x3f_get4(f);
  Result := _tmp.f;
end;

function x3f_get_camf(_x3f: Px3f): Px3f_directory_entry;
begin
  Result := x3f_get(_x3f, X3F_SECc, 0);
end;

//* --------------------------------------------------------------------- */
//* Allocating Huffman tree help data                                   */
//* --------------------------------------------------------------------- */

procedure cleanup_huffman_tree(HTP: Px3f_hufftree);
begin
  FreeMem(HTP.nodes);
end;

procedure new_huffman_tree(HTP: Px3f_hufftree; bits: Integer);
var
  leaves: Integer;
begin
  leaves := 1 shl bits;

  HTP.free_node_index := 0;
  GetMem(HTP.nodes, HUF_TREE_MAX_NODES(leaves) * SizeOf(x3f_huffnode));
end;

procedure cleanup_huffman(var HUFP: Px3f_huffman);
begin
  if Assigned(HUFP) then
  begin
  //  x3f_printf(DEBUG, "Cleanup Huffman\n");

    FreeMem(HUFP.mapping.element);
    FreeMem(HUFP.table.element);
    cleanup_huffman_tree(@(HUFP.tree));
    FreeMem(HUFP.row_offsets.element);
    FreeMem(HUFP.rgb8.buf);
    FreeMem(HUFP.x3rgb16.buf);
    FreeMem(HUFP);
  end;

  HUFP := nil;
end;

function new_huffman(var HUFP: Px3f_huffman): Px3f_huffman;
begin
  GetMem(Result, SizeOf(x3f_huffman));

  cleanup_huffman(HUFP);

  //* Set all not read data block pointers to NULL */
  Result.mapping.size := 0;
  Result.mapping.element := nil;
  Result.table.size := 0;
  Result.table.element := nil;
  Result.tree.nodes := nil;
  Result.row_offsets.size := 0;
  Result.row_offsets.element := nil;
  Result.rgb8.data := nil;
  Result.rgb8.buf := nil;
  Result.x3rgb16.data := nil;
  Result.x3rgb16.buf := nil;

  HUFP := Result;
end;

//* --------------------------------------------------------------------- */
//* Creating a new x3f structure from file                                */
//* --------------------------------------------------------------------- */
function x3f_new_from_file(in_file: Integer): Px3f;
var
  i, d, num_ext_data: Integer;
  _size, save_dir_pos: Cardinal;
  _Info: ^x3f_info;
  _Header: ^x3f_header;
  _DirSection: ^x3f_directory_section;
  _DirEntry: Px3f_directory_entry;
  _DirEntryHeader: ^x3f_directory_entry_header;
  _PropList: ^x3f_property_list;
  _ImageData: ^x3f_image_data;
  _CamF: ^x3f_camf_t;
begin
   New(Result);
  _Info := nil;
  _Header := nil;
  _DirSection := nil;

  _Info := @(Result.info);
  _Info.error := '';
  _Info.in_file := in_file;
  _Info.out_file := 0;

  if in_file = 0 then
  begin
    _Info.error := 'No infile';
    Exit(Result);
  end;

  //* Read file header */
  _Header := @Result.header;
  FileSeek(in_file, 0, 0);
  _Header.identifier := x3f_get4(in_file);

  if _Header.identifier <> X3F_FOVb then
  begin
//    x3f_printf(ERR, "Faulty file type\n");
//    x3f_delete(x3f);  //!!!
    Exit(nil);
  end;

  _Header.version := x3f_get4(in_file);

  FileRead(in_file, _Header.unique_identifier, SIZE_UNIQUE_IDENTIFIER);
  //* TODO: the meaning of the rest of the header for version >= 4.0
  //         (Quattro) is unknown */
  if _Header.version < X3F_VERSION_4_0 then
  begin
    _Header.mark_bits := x3f_get4(in_file);
    _Header.columns := x3f_get4(in_file);
    _Header.rows := x3f_get4(in_file);
    _Header.rotation := x3f_get4(in_file);

    if _Header.version >= X3F_VERSION_2_1 then
    begin
      if _Header.version >= X3F_VERSION_3_0 then
        num_ext_data := NUM_EXT_DATA_3_0
      else
        num_ext_data := NUM_EXT_DATA_2_1;

      FileRead(in_file, _Header.white_balance, SIZE_WHITE_BALANCE);

      if _Header.version >= X3F_VERSION_2_3 then
	      FileRead(in_file, _Header.color_mode, SIZE_COLOR_MODE);

      FileRead(in_file, _Header.extended_types, num_ext_data);
      for i := 0 to num_ext_data - 1 do
	      _Header.extended_data[i] := x3f_get4f(in_file);
    end;
  end;

  //* Go to the beginning of the directory */
  FileSeek(in_file, -4, 2);
  FileSeek(in_file, x3f_get4(in_file), 0);

  //* Read the directory header */
  _DirSection := @(Result.directory_section);
  _DirSection.identifier := x3f_get4(in_file);
  _DirSection.version := x3f_get4(in_file);
  _DirSection.num_directory_entries := x3f_get4(in_file);

  if _DirSection.num_directory_entries > 0 then
  begin
    _size := _DirSection.num_directory_entries * SizeOf(x3f_directory_entry);
    _DirSection.directory_entry := GetMemory(_size);
  end;

  //* Traverse the directory */
  _DirEntry := _DirSection.directory_entry;
  for d := 0 to _DirSection.num_directory_entries - 1 do
  begin
    _DirEntryHeader := @(_DirEntry.header);

    //* Read the directory entry info */
    _DirEntry.input.offset := x3f_get4(in_file);
    _DirEntry.input.size := x3f_get4(in_file);

    _DirEntry.output.offset := 0;
    _DirEntry.output.size := 0;

    _DirEntry.&type := x3f_get4(in_file);


    //* Save current pos and go to the entry */
    save_dir_pos := FileSeek(in_file, 0, 1);
    FileSeek(in_file, _DirEntry.input.offset, 0);

    //* Read the type independent part of the entry header */
    _DirEntryHeader := @(_DirEntry.header);
    _DirEntryHeader.identifier := x3f_get4(in_file);
    _DirEntryHeader.version := x3f_get4(in_file);

    //* NOTE - the tests below could be made on _DirEntry.type instead */

    if _DirEntryHeader.identifier = X3F_SECp then
    begin
      _PropList := @(_DirEntryHeader.data_subsection.property_list);

      //* Read the property part of the header */
      _PropList.num_properties := x3f_get4(in_file);
      _PropList.character_format := x3f_get4(in_file);
      _PropList.reserved := x3f_get4(in_file);
      _PropList.total_length := x3f_get4(in_file);

      //* Set all not read data block pointers to NULL */
      _PropList.data := nil;
      _PropList.data_size := 0;
    end;

    if _DirEntryHeader.identifier = X3F_SECi then
    begin
      _ImageData := @(_DirEntryHeader.data_subsection.image_data);

      //* Read the image part of the header */
      _ImageData.&type := x3f_get4(in_file);
      _ImageData.format := x3f_get4(in_file);
      _ImageData.type_format := (_ImageData.&type shl 16) + (_ImageData.format);
      _ImageData.columns := x3f_get4(in_file);
      _ImageData.rows := x3f_get4(in_file);
      _ImageData.row_stride := x3f_get4(in_file);

      //* Set all not read data block pointers to NULL */
      _ImageData.huffman := nil;

      _ImageData.data := nil;
      _ImageData.data_size := 0;
    end;

    if _DirEntryHeader.identifier = X3F_SECc then
    begin
      _CamF := @(_DirEntryHeader.data_subsection.camf);

      //* Read the CAMF part of the header */
      _CamF.&type := x3f_get4(in_file);
      _CamF.tN.val0 := x3f_get4(in_file);
      _CamF.tN.val1 := x3f_get4(in_file);
      _CamF.tN.val2 := x3f_get4(in_file);
      _CamF.tN.val3 := x3f_get4(in_file);

      //* Set all not read data block pointers to NULL */
      _CamF.data := nil;
      _CamF.data_size := 0;

      //* Set all not allocated help pointers to NULL */
      _CamF.table.element := nil;
      _CamF.table.size := 0;
      _CamF.tree.nodes := nil;
      _CamF.decoded_data := nil;
      _CamF.decoded_data_size := 0;
      _CamF.entry_table.element := nil;
      _CamF.entry_table.size := 0;
    end;

    Inc(_DirEntry);

    //* Reset the file pointer back to the directory */
    FileSeek(in_file, save_dir_pos, 0);
  end;
end;

//* --------------------------------------------------------------------- */
//* Loading the data in a directory entry                                 */
//* --------------------------------------------------------------------- */
procedure Get_Table2(AFileHandle: THandle; var ATable: x3f_table16; ANumber: Integer);
var
  i: Integer;
  _element: System.PWord;
begin
  ATable.size := ANumber;
  ReallocMem(ATable.element, ANumber * SizeOf(ATable.element^));

  _element := ATable.element;
  for i := 0 to ANumber - 1 do
  begin
    _element^ := x3f_get2(AFileHandle);
    Inc(_element);
  end;
end;

procedure Get_Table4(AFileHandle: THandle; var ATable: x3f_table32; ANumber: Integer);
var
  i: Integer;
  _element: PCardinal;
begin
  ATable.size := ANumber;
  ReallocMem(ATable.element, ANumber * SizeOf(ATable.element^));

  _element := ATable.element;
  for i := 0 to ANumber - 1 do
  begin
    _element^ := x3f_get4(AFileHandle);
    Inc(_element);
  end;
end;

procedure Get_Property_Table(AFileHandle: THandle; APropTable: Px3f_property_table; ANumber: Integer);
var
  i: Integer;
  _element: Px3f_property;
begin
  APropTable.size := ANumber;
  GetMem(APropTable.element, ANumber * SizeOf(APropTable.element^));

  _element := APropTable.element;

  for i := 0 to APropTable.size - 1 do
  begin
    _element.name_offset := x3f_get4(AFileHandle);
    _element.value_offset := x3f_get4(AFileHandle);

    Inc(_element);
  end
end;

procedure Get_True_Huff_Table(AFileHandle: THandle; ATrueHuffTable: Px3f_true_huffman_table);
var
  i: Integer;
  _element: Px3f_true_huffman_element;
begin
  ATrueHuffTable.element := nil;
  i := 0;

  while True do
  begin
    ATrueHuffTable.size := i + 1;
    ReallocMem(ATrueHuffTable.element, (i + 1) * SizeOf(ATrueHuffTable.element^));
    if i = 0 then
      _element := ATrueHuffTable.element;

    _element.code_size := x3f_get1(AFileHandle);
    _element.code := x3f_get1(AFileHandle);

    if _element.code_size = 0 then
      break;

    Inc(_element);
    Inc(i);
  end;
end;

function new_node(var tree: x3f_hufftree): Px3f_huffnode;
begin
  Result := tree.nodes;
  Inc(Result, tree.free_node_index);

  Result.branch[0] := nil;
  Result.branch[1] := nil;
  Result.leaf := UNDEFINED_LEAF;

  Inc(tree.free_node_index);
end;

procedure add_code_to_tree(var tree: x3f_hufftree; _length: Integer;
  _code, value: Cardinal);
var
  i, _pos, _bit: Integer;
  _t, _t_next: Px3f_huffnode;
begin
   _t := tree.nodes;

  for i := 0 to _length - 1 do
  begin
    _pos := _length - i - 1;
    _bit := (_code shr _pos) and 1;
    _t_next := _t.branch[_bit];

    if _t_next = nil then
    begin
      _t.branch[_bit] := new_node(tree);
      _t_next := _t.branch[_bit];
    end;

    _t := _t_next;
  end;

  _t.leaf := value;
end;

procedure populate_true_huffman_tree(var tree: x3f_hufftree;
  var table: x3f_true_huffman_table);
var
  i: Integer;
  _element: Px3f_true_huffman_element;
  _length, _code, _value: Cardinal;
begin
  new_node(tree);

  _element := table.element;
  for i :=0 to table.size - 1 do
  begin
    _length := _element.code_size;

    if _length <> 0 then
    begin
      //* add_code_to_tree wants the code right adjusted */
      _code := (_element.code shr (8 - _length)) and $FF;
      _value := i;

      add_code_to_tree(tree, _length, _code, _value);
    end;

    Inc(_element);
  end;
end;

function HUF_TREE_GET_LENGTH(AValue: Cardinal): Cardinal; inline;
begin
  Result := (AValue shr 27) and $1F;
end;

function HUF_TREE_GET_CODE(AValue: Cardinal): Cardinal; inline;
begin
  Result := AValue and $07FFFFFF;
end;

procedure populate_huffman_tree(var tree: x3f_hufftree; var table: x3f_table32;
  var mapping: x3f_table16);
var
  i: Integer;
  _element: PCardinal;
  _value, _length, _code: Cardinal;
  _tmp: System.PWord;
begin
  new_node(tree);

  _element := table.element;

  for i := 0 to table.size - 1 do
  begin
    if _element <> nil then
    begin
      _length := HUF_TREE_GET_LENGTH(_element^);
      _code := HUF_TREE_GET_CODE(_element^);

      (* If we have a valid mapping table - then the value from the
         mapping table shall be used. Otherwise we use the current
         index in the table as value. *)
      if table.size = mapping.size then
      begin
        _tmp := mapping.element;
        Inc(_tmp, i);
        _value := _tmp^;
      end
      else
        _value := i;

      add_code_to_tree(tree, _length, _code, _value);

(*#ifdef DBG_PRNT
      {
        char buffer[100];

        x3f_printf(DEBUG, "H %5d : %5x : %5d : %02x %08x (%08x) (%s)\n",
		   i, i, value, length, code, element,
		   display_code(length, code, buffer));
      }
#endif*)
    end;

    Inc(_element);
  end;
end;

//* First you set the offset to where to start reading the data ... */

procedure read_data_set_offset(I: Px3f_info; DE: Px3f_directory_entry;
  header_size: uint32);
var
  i_off: uint32;
begin
  i_off := DE.input.offset + header_size;

  FileSeek(I.in_file, i_off, 0);
end;

//* ... then you read the data, block for block */

function read_data_block(var data; I: Px3f_info; DE: Px3f_directory_entry;
  footer: uint32): uint32;
var
  _data: PByte;
begin
  Result := DE.input.size + DE.input.offset - FileSeek(I.in_file, 0, 1) - footer;

  _data := PByte(@data);
  GetMem(_data, Result);

  Result := FileRead(I.in_file, _data, Result);
end;

procedure x3f_load_image_verbatim(I: Px3f_info; DE: Px3f_directory_entry);
var
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
begin
  DEH := @(DE.header);
  ID := @(DEH.data_subsection.image_data);

//  x3f_printf(DEBUG, "Load image verbatim\n");

  ID.data_size := read_data_block(ID.data, I, DE, 0);
end;

procedure x3f_load_property_list(Info: Px3f_info; DE: Px3f_directory_entry);
var
  DEH: Px3f_directory_entry_header;
  PL: Px3f_property_list;
  P: Px3f_property;
  i: Integer;
begin
  DEH := @(DE.header);
  PL := @(DEH.data_subsection.property_list);

  read_data_set_offset(Info, DE, X3F_PROPERTY_LIST_HEADER_SIZE);

  Get_Property_Table(Info.in_file, @(PL.property_table), PL.num_properties);

  PL.data_size := read_data_block(PL.data, Info, DE, 0);

  P := PL.property_table.element;

  for i := 0  to PL.num_properties - 1 do
  begin
    P.name := PWideChar(PL.data) + P.name_offset;
    P.value := PWideChar(PL.data) + P.value_offset;
    P.name_utf8 := P.name;    //???
    P.value_utf8 := P.value;  //???

    Inc(P);
  end;
end;

//* --------------------------------------------------------------------- */
//* Allocating TRUE engine RAW help data                                  */
//* --------------------------------------------------------------------- */

procedure cleanup_true(var TRUP: Px3f_true_t);
begin
  if Assigned(TRUP) then
  begin
//    x3f_printf(DEBUG, "Cleanup TRUE data\n");

    FreeMem(TRUP.table.element);
    FreeMem(TRUP.plane_size.element);
    cleanup_huffman_tree(@(TRUP.tree));
    FreeMem(TRUP.x3rgb16.buf);

    FreeMem(TRUP);
  end;

  TRUP := nil;
end;

function new_true(var TRUP: Px3f_true_t): Px3f_true_t;
var
  TRU: Px3f_true_t;
begin
  GetMem(TRU, SizeOf(x3f_true_t));

  cleanup_true(TRUP);

  with TRU^ do
  begin
    table.size := 0;
    table.element := nil;
    plane_size.size := 0;
    plane_size.element := nil;
    tree.nodes := nil;
    x3rgb16.data := nil;
    x3rgb16.buf := nil;
  end;

  TRUP := TRU;

  Result := TRU;
end;

procedure cleanup_quattro(var QP: Px3f_quattro);
begin
  if Assigned(QP) then
  begin
//    x3f_printf(DEBUG, "Cleanup Quattro\n");

    FreeMem(QP.top16.buf);
    FreeMem(QP);
  end;

  QP := nil;
end;

function new_quattro(var QP: Px3f_quattro): Px3f_quattro;
var
  i: Integer;
  Q: Px3f_quattro;
begin
  GetMem(Q, SizeOf(x3f_quattro));

  cleanup_quattro(QP);

  for i := 0 to TRUE_PLANES - 1 do
  begin
    Q.plane[i].columns := 0;
    Q.plane[i].rows := 0;
  end;

  Q.unknown := 0;

  Q.top16.data := nil;
  Q.top16.buf := nil;

  QP := Q;

  Result := Q;
end;

//* Help machinery for reading bits in a memory */

type
  bit_state = record
    next_address: PByte;
    bit_offset: Byte;
    bits: array[0..7] of Byte;
  end;
  Pbit_state = ^bit_state;

procedure set_bit_state(var BS: bit_state; address: PByte);
begin
  BS.next_address := address;
  BS.bit_offset := 8;
end;

function get_bit(var BS: bit_state): Byte;
var
  _byte: Byte;
  i: Integer;
begin
  if BS.bit_offset = 8 then
  begin
    _byte := BS.next_address^;

    for i := 7 downto 0 do
    begin
      BS.bits[i] := _byte and 1;
      _byte := _byte shr 1;
    end;

    Inc(BS.next_address);
    BS.bit_offset := 0;
  end;

  Result := BS.bits[BS.bit_offset + 1];
end;

//* Decode use the TRUE algorithm */

function get_true_diff(var BS: bit_state; HTP: Px3f_hufftree): Integer;
var
  diff, i: Integer;
  _node, new_node: Px3f_huffnode;
  bits, bit, first_bit: Byte;
begin
   _node := HTP.nodes;

  while (_node.branch[0] <> nil) or (_node.branch[1] <> nil) do
  begin
    bit := get_bit(BS);
    new_node := _node.branch[bit];

    _node := new_node;
    if _node = nil then
    begin
      //* , bitTODO: Shouldn't this be treated as a fatal error? */
//      x3f_printf(ERR, "Huffman coding got unexpected bit\n");
      Exit(0);
    end;
  end;

  bits := _node.leaf;

  if bits = 0 then
    diff := 0
  else
    begin
      first_bit := get_bit(BS);

      diff := first_bit;

      for i := 1 to bits - 1 do
        diff := (diff shl 1) + get_bit(BS);

      if first_bit = 0 then
        diff := diff - (1 shl bits) - 1;
    end;

  Result := diff;
end;

(* This code (that decodes one of the X3F color planes, really is a
   decoding of a compression algorithm suited for Bayer CFA data. In
   Bayer CFA the data is divided into 2x2 squares that represents
   (R,G1,G2,B) data. Those four positions are (in this compression)
   treated as one data stream each, where you store the differences to
   previous data in the stream. The reason for this is, of course,
   that the date is more often than not near to the next data in a
   stream that represents the same color. *)

//* TODO: write more about the compression */

procedure true_decode_one_color(ID: Px3f_image_data; color: Integer);
var
  TRU: Px3f_true_t;
  Q: Px3f_quattro;
  seed: uint32;
  _row, _col, diff, prev, _value: Integer;
  _tree: Px3f_hufftree;
  BS: bit_state;
  row_start_acc: array[0..1, 0..1] of Integer;
  rows, cols: Cardinal;
  _area: Px3f_area16;
  _dst: System.PWord;
  odd_row, odd_col: Boolean;
  acc: array[0..1] of Integer;
begin
  TRU := ID.tru;
  Q := ID.quattro;
  seed := TRU.seed[color]; //* TODO : Is this correct ? */

  _tree := @(TRU.tree);

  rows := ID.rows;
  cols := ID.columns;
  _area := @(TRU.x3rgb16);
  _dst := _area.data;
  Inc(_dst, color);

  set_bit_state(BS, TRU.plane_address[color]);

  row_start_acc[0][0] := seed;
  row_start_acc[0][1] := seed;
  row_start_acc[1][0] := seed;
  row_start_acc[1][1] := seed;

  if (ID.type_format = X3F_IMAGE_RAW_QUATTRO) or
    (ID.type_format = X3F_IMAGE_RAW_SDQ) or
    (ID.type_format = X3F_IMAGE_RAW_SDQH) then
  begin
    rows := Q.plane[color].rows;
    cols := Q.plane[color].columns;

    if Q.quattro_layout and (color = 2) then
    begin
      _area := @(Q.top16);
      _dst := _area.data;
    end;
{
    x3f_printf(DEBUG, "Quattro decode one color (%d) rows=%d cols=%d\n",
	       color, rows, cols);}
  end
{  else
    x3f_printf(DEBUG, "TRUE decode one color (%d) rows=%d cols=%d\n",
	       color, rows, cols);
};

  Assert((rows = _area.rows) and (cols >= _area.columns));

  for _row := 0 to rows - 1 do
  begin
    odd_row := Odd(_row);

    for _col := 0 to cols - 1 do
    begin
      odd_col := Odd(_col);
      diff := get_true_diff(BS, _tree);
      if _col < 2 then
        prev := row_start_acc[Integer(odd_row)][Integer(odd_col)]
      else
        prev := acc[Integer(odd_col)];

      _value := prev + diff;

      acc[Integer(odd_col)] := _value;
      if _col < 2 then
	      row_start_acc[Integer(odd_row)][Integer(odd_col)] := _value;

      //* Discard additional data at the right for binned Quattro plane 2 */
      if _col >= _area.columns then
        continue;

      _dst^ := _value;
      Inc(_dst, _area.channels);
    end;
  end;
end;

procedure true_decode(I: Px3f_info;	DE: Px3f_directory_entry);
var
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
  color: Integer;
begin
  DEH := @(DE.header);
  ID := @(DEH.data_subsection.image_data);

  for color := 0 to 2 do
    true_decode_one_color(ID, color);
end;

procedure x3f_load_true(Info: Px3f_info; DE: Px3f_directory_entry);
var
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
  TRU: Px3f_true_t;
  Q: Px3f_quattro;
  i: Integer;
  columns, rows, channels, _size: Cardinal;
  _element: PCardinal;
begin
  DEH := @(DE.header);
  ID := @(DEH.data_subsection.image_data);
  TRU := new_true(ID.tru);
  Q := nil;

  if (ID.type_format = X3F_IMAGE_RAW_QUATTRO) or
    (ID.type_format = X3F_IMAGE_RAW_SDQ) or
    (ID.type_format = X3F_IMAGE_RAW_SDQH) then
  begin
//    x3f_printf(DEBUG, "Load Quattro extra info\n");

    Q := new_quattro(ID.quattro);

    for i := 0 to TRUE_PLANES - 1 do
    begin
      Q.plane[i].columns := x3f_get2(Info.in_file);
      Q.plane[i].rows := x3f_get2(Info.in_file);
    end;

    if Q.plane[0].rows = ID.rows / 2 then
    begin
//      x3f_printf(DEBUG, "Quattro layout\n");
      Q.quattro_layout := True;
    end
    else
      if Q.plane[0].rows = ID.rows then
      begin
//        x3f_printf(DEBUG, "Binned Quattro\n");
        Q.quattro_layout := False;
      end
      else
        begin
//          x3f_printf(ERR, "Quattro file with unknown layer size\n");
          assert(False);
        end;
  end;

//  x3f_printf(DEBUG, "Load TRUE\n");

  //* Read TRUE header data */
  TRU.seed[0] := x3f_get2(Info.in_file);
  TRU.seed[1] := x3f_get2(Info.in_file);
  TRU.seed[2] := x3f_get2(Info.in_file);
  TRU.unknown := x3f_get2(Info.in_file);
  Get_True_Huff_Table(Info.in_file, @(TRU.table));

  if (ID.type_format = X3F_IMAGE_RAW_QUATTRO) or
    (ID.type_format = X3F_IMAGE_RAW_SDQ) or
    (ID.type_format = X3F_IMAGE_RAW_SDQH) then
  begin
//    x3f_printf(DEBUG, "Load Quattro extra info 2\n");

    Q.unknown := x3f_get4(Info.in_file);
  end;

  Get_Table4(Info.in_file, TRU.plane_size, TRUE_PLANES);

  //* Read image data */
  ID.data_size := read_data_block(ID.data, Info, DE, 0);

  //* TODO: can it be fewer than 8 bits? Maybe taken from TRU->table? */
  new_huffman_tree(@(TRU.tree), 8);

  populate_true_huffman_tree(TRU.tree, TRU.table);

  TRU.plane_address[0] := ID.data;
  _element := TRU.plane_size.element;
  for i := 1 to TRUE_PLANES - 1 do
  begin
    TRU.plane_address[i] := TRU.plane_address[i-1] + (_element^ + 15) div 16 * 16;
    Inc(_element);
  end;

  if ((ID.type_format = X3F_IMAGE_RAW_QUATTRO) or
	  (ID.type_format = X3F_IMAGE_RAW_SDQ) or
	  (ID.type_format = X3F_IMAGE_RAW_SDQH)) and
    Q.quattro_layout then
  begin
    columns := Q.plane[0].columns;
    rows := Q.plane[0].rows;
    channels := 3;
    _size := columns * rows * channels;

    TRU.x3rgb16.columns := columns;
    TRU.x3rgb16.rows := rows;
    TRU.x3rgb16.channels := channels;
    TRU.x3rgb16.row_stride := columns * channels;
    GetMem(TRU.x3rgb16.buf, SizeOf(uint16) * _size);
    TRU.x3rgb16.data := TRU.x3rgb16.buf;

    columns := Q.plane[2].columns;
    rows := Q.plane[2].rows;
    channels := 1;
    _size := columns * rows * channels;

    Q.top16.columns := columns;
    Q.top16.rows := rows;
    Q.top16.channels := channels;
    Q.top16.row_stride := columns * channels;
    GetMem(Q.top16.buf, SizeOf(uint16) * _size);
    Q.top16.data := Q.top16.buf;
  end
  else
    begin
      _size := ID.columns * ID.rows * 3;

      TRU.x3rgb16.columns := ID.columns;
      TRU.x3rgb16.rows := ID.rows;
      TRU.x3rgb16.channels := 3;
      TRU.x3rgb16.row_stride := ID.columns * 3;
      GetMem(TRU.x3rgb16.buf, SizeOf(uint16) * _size);
      TRU.x3rgb16.data := TRU.x3rgb16.buf;
    end;

  true_decode(Info, DE);
end;

//* Decode use the huffman tree */

function get_huffman_diff(BS: Pbit_state; HTP: Px3f_hufftree): Integer;
var
  _node, new_node: Px3f_huffnode;
  bit: Byte;
begin
  _node := HTP.nodes;

  while Assigned(_node.branch[0]) or Assigned(_node.branch[1]) do
  begin
    bit := get_bit(BS^);
    new_node := _node.branch[bit];

    _node := new_node;
    if _node = nil then
    begin
      //* TODO: Shouldn't this be treated as a fatal error? */
//      x3f_printf(ERR, "Huffman coding got unexpected bit\n");
      Exit(0);
    end;
  end;

  Result := _node.leaf;
end;

procedure huffman_decode_row(I: Px3f_info; DE: Px3f_directory_entry;
  bits, row, offset: Integer; minimum: PInteger);
var
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
  HUF: Px3f_huffman;
  c: array[0..2] of ShortInt;
  col, _color: Integer;
  BS: bit_state;
  _element: PCardinal;
  c_fix: Word;
  _dataW: System.PWord;
  _dataB: PByte;
begin
  DEH := @(DE.header);
  ID := @(DEH.data_subsection.image_data);
  HUF := ID.huffman;

  for col := 0 to 2 do
    c[col] := offset;

  _element := HUF.row_offsets.element;
  Inc(_element, row);
  set_bit_state(BS, PByte(ID.data) + _element^);

  for col := 0 to ID.columns - 1 do
  begin
    for _color := 0 to 2 do
    begin
      Inc(c[_color], get_huffman_diff(@BS, @(HUF.tree)));
      if c[_color] < 0 then
      begin
        c_fix := 0;
        if c[_color] < minimum^ then
          minimum^ := c[_color];
      end
      else
        c_fix := c[_color];

      case ID.type_format of
      X3F_IMAGE_RAW_HUFFMAN_X530,
      X3F_IMAGE_RAW_HUFFMAN_10BIT:
        begin
          _dataW := HUF.x3rgb16.data;
          Inc(_dataW, 3 * (row * ID.columns + col) + _color);
          _dataW^ := c_fix;
        end;
      X3F_IMAGE_THUMB_HUFFMAN:
        begin
          _dataB := HUF.rgb8.data;
          Inc(_dataB, 3 * (row * ID.columns + col) + _color);
          _dataB^ := Byte(c_fix);
        end;
      else
//* TODO: Shouldn't this be treated as a fatal error? */
//        x3f_printf(ERR, "Unknown huffman image type\n");
      end;
    end;
  end;
end;

procedure huffman_decode(I: Px3f_info; DE: Px3f_directory_entry; bits: Integer);
var
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
  row, minimum, offset: Integer;
begin
  DEH := @(DE.header);
  ID := @(DEH.data_subsection.image_data);

  minimum := 0;
  offset := legacy_offset;

//  x3f_printf(DEBUG, "Huffman decode with offset: %d\n", offset);
  for row := 0 to ID.rows - 1 do
    huffman_decode_row(I, DE, bits, row, offset, @minimum);

  if auto_legacy_offset and (minimum < 0) then
  begin
    offset := -minimum;
//    x3f_printf(DEBUG, "Redo with offset: %d\n", offset);
    for row := 0 to ID.rows - 1 do
      huffman_decode_row(I, DE, bits, row, offset, @minimum);
  end;
end;

function get_simple_diff(HUF: Px3f_huffman; index: Word): Word;
var
  _element: System.PWord;
begin
  if HUF.mapping.size = 0 then
    Result := index
  else
    begin
      _element := HUF.mapping.element;
      Inc(_element, index);
      Result := _element^;
    end;
end;

procedure simple_decode_row(I: Px3f_info; DE: Px3f_directory_entry;
  bits, row, row_stride: Integer);
var
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
  HUF: Px3f_huffman;
  _data: PCardinal;
  c: array[0..2] of Word;
  col, _color: Integer;
  mask, val: Cardinal;
  c_fix: Word;
  _dataW: System.PWord;
  _dataB: PByte;
begin
  DEH := @(DE.header);
  ID := @(DEH.data_subsection.image_data);
  HUF := ID.huffman;

  _data := ID.data;
  Inc(_data, row * row_stride);

  for col := 0 to 2 do
    c[col] := 0;

  mask := 0;

  case bits of
  8:
    mask := $0ff;
  9:
    mask := $1ff;
  10:
    mask := $3ff;
  11:
    mask := $7ff;
  12:
    mask := $fff;
  else
    //* TODO: Shouldn't this be treated as a fatal error? */
//    x3f_printf(ERR, "Unknown number of bits: %d\n", bits);
    mask := 0;
  end;

  for col := 0 to ID.columns do
  begin
    val := _data^;

    for _color := 0 to 3 do
    begin
      Inc(c[_color], get_simple_diff(HUF, val shr (_color * bits)) and mask);

      case ID.type_format of
      X3F_IMAGE_RAW_HUFFMAN_X530,
      X3F_IMAGE_RAW_HUFFMAN_10BIT:
        begin
          if c[_color] > 0 then
            c_fix := c[_color]
          else
            c_fix := 0;
          _dataW := HUF.x3rgb16.data;
          Inc(_dataW, 3 * (row * ID.columns + col) + _color);
          _dataW^ := c_fix;
        end;
      X3F_IMAGE_THUMB_HUFFMAN:
        begin
          if c[_color] > 0 then
            c_fix := c[_color]
          else
            c_fix := 0;
          _dataB := HUF.rgb8.data;
          Inc(_dataB, 3 * (row * ID.columns + col) + _color);
          _dataB^ := Byte(c_fix);
        end;
      else
	//* TODO: Shouldn't this be treated as a fatal error? */
//        x3f_printf(ERR, "Unknown huffman image type\n");
      end;
    end;

    Inc(_data);
  end;
end;

procedure simple_decode(I: Px3f_info; DE: Px3f_directory_entry;
  bits, row_stride: Integer);
var
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
  row: Integer;
begin
  DEH := @(DE.header);
  ID := @(DEH.data_subsection.image_data);

  for row := 0 to ID.rows - 1 do
    simple_decode_row(I, DE, bits, row, row_stride);
end;

procedure x3f_load_huffman_compressed(I: Px3f_info; DE: Px3f_directory_entry;
  bits: Integer; use_map_table: Boolean);
var
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
  HUF: Px3f_huffman;
  table_size, row_offsets_size: Integer;
begin
  DEH := @(DE.header);
  ID := @(DEH.data_subsection.image_data);
  HUF := ID.huffman;
  table_size := 1 shl bits;
  row_offsets_size := ID.rows * SizeOf(HUF.row_offsets.element^);

//  x3f_printf(DEBUG, "Load huffman compressed\n");

  Get_Table4(I.in_file, HUF.table, table_size);

  ID.data_size := read_data_block(ID.data, I, DE, row_offsets_size);

  Get_Table4(I.in_file, HUF.row_offsets, ID.rows);

//  x3f_printf(DEBUG, "Make huffman tree ...\n");
  new_huffman_tree(@(HUF.tree), bits);
  populate_huffman_tree(HUF.tree, HUF.table, HUF.mapping);
//  x3f_printf(DEBUG, "... DONE\n");

{#ifdef DBG_PRNT
  print_huffman_tree(HUF->tree.nodes, 0, 0);
#endif
}
  huffman_decode(I, DE, bits);
end;

procedure x3f_load_huffman_not_compressed(I: Px3f_info; DE: Px3f_directory_entry;
  bits: Integer; use_map_table: Boolean; row_stride: Integer);
var
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
begin
  DEH := @(DE.header);
  ID := @(DEH.data_subsection.image_data);

//  x3f_printf(DEBUG, "Load huffman not compressed\n");

  ID.data_size := read_data_block(ID.data, I, DE, 0);

  simple_decode(I, DE, bits, row_stride);
end;

procedure x3f_load_huffman(I: Px3f_info; DE: Px3f_directory_entry;
  bits: Integer; use_map_table: Boolean; row_stride: Integer);
var
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
  HUF: Px3f_huffman;
  _size: Cardinal;
  table_size: Integer;
begin
  DEH := @(DE.header);
  ID := @(DEH.data_subsection.image_data);
  HUF := new_huffman(ID.huffman);

  if use_map_table then
  begin
    table_size := 1 shl bits;

    Get_Table2(I.in_file, HUF.mapping, table_size);  //???!!!
  end;

  case ID.type_format of
  X3F_IMAGE_RAW_HUFFMAN_X530,
  X3F_IMAGE_RAW_HUFFMAN_10BIT:
    begin
      _size := ID.columns * ID.rows * 3;
      HUF.x3rgb16.columns := ID.columns;
      HUF.x3rgb16.rows := ID.rows;
      HUF.x3rgb16.channels := 3;
      HUF.x3rgb16.row_stride := ID.columns * 3;
      GetMem(HUF.x3rgb16.buf, SizeOf(uint16) * _size);
      HUF.x3rgb16.data := HUF.x3rgb16.buf;
    end;
  X3F_IMAGE_THUMB_HUFFMAN:
    begin
      _size := ID.columns * ID.rows * 3;
      HUF.rgb8.columns := ID.columns;
      HUF.rgb8.columns := ID.rows;
      HUF.rgb8.channels := 3;
      HUF.rgb8.row_stride := ID.columns * 3;
      GetMem(HUF.rgb8.buf, SizeOf(uint8) * _size);
      HUF.rgb8.data := HUF.rgb8.buf;
    end;
  else
    //* TODO: Shouldn't this be treated as a fatal error? */
//    x3f_printf(ERR, "Unknown huffman image type\n");
  end;

  if row_stride = 0 then
    x3f_load_huffman_compressed(I, DE, bits, use_map_table)
  else
    x3f_load_huffman_not_compressed(I, DE, bits, use_map_table, row_stride);
end;

procedure x3f_load_pixmap(I: Px3f_info; DE: Px3f_directory_entry);
begin
//  x3f_printf(DEBUG, "Load pixmap\n");
  x3f_load_image_verbatim(I, DE);
end;

procedure x3f_load_jpeg(I: Px3f_info; DE: Px3f_directory_entry);
begin
//  x3f_printf(DEBUG, "Load JPEG\n");
  x3f_load_image_verbatim(I, DE);
end;

procedure x3f_load_image(I: Px3f_info; DE: Px3f_directory_entry);
var
  DEH: Px3f_directory_entry_header;
  ID: Px3f_image_data;
begin
  DEH := @(DE.header);
  ID := @(DEH.data_subsection.image_data);

  read_data_set_offset(I, DE, X3F_IMAGE_HEADER_SIZE);

  case ID.type_format of
  X3F_IMAGE_RAW_TRUE,
  X3F_IMAGE_RAW_MERRILL,
  X3F_IMAGE_RAW_QUATTRO,
  X3F_IMAGE_RAW_SDQ,
  X3F_IMAGE_RAW_SDQH:
    x3f_load_true(I, DE);
  X3F_IMAGE_RAW_HUFFMAN_X530,
  X3F_IMAGE_RAW_HUFFMAN_10BIT:
    x3f_load_huffman(I, DE, 10, True, ID.row_stride);
  X3F_IMAGE_THUMB_PLAIN:
    x3f_load_pixmap(I, DE);
  X3F_IMAGE_THUMB_HUFFMAN:
    x3f_load_huffman(I, DE, 8, False, ID.row_stride);
  X3F_IMAGE_THUMB_JPEG:
    x3f_load_jpeg(I, DE);
  else
    //* TODO: Shouldn't this be treated as a fatal error? */
//    x3f_printf(ERR, "Unknown image type\n");
  end;
end;

procedure x3f_setup_camf_text_entry(entry: Pcamf_entry);
begin
  entry.text_size := PCardinal(entry.value_address)^;
  entry.text := PAnsiChar(entry.value_address) + 4;
end;

procedure x3f_setup_camf_property_entry(entry: Pcamf_entry);
var
  i: Integer;
  _e, _v: PByte;
  num, off, name_off, value_off: Cardinal;
begin
  _e := entry.entry;
  _v := entry.value_address;
  entry.property_num := _v^;
  num := entry.property_num;
  off := (_v + 4)^;

  GetMem(entry.property_name^, num * SizeOf(PByte));
  GetMem(entry.property_value^, num * SizeOf(PByte));

  for i := 0 to num - 1 do
  begin
    name_off := off + (_v + 8 + 8 * i)^;
    value_off := off + (_v + 8 + 8 * i + 4)^;

    entry.property_name := Pointer(_e + name_off);
    entry.property_value := Pointer(_e + value_off);
    Inc(entry.property_name);
    Inc(entry.property_value);
  end;
end;

procedure set_matrix_element_info(AType: Cardinal; var ASize: Cardinal;
  var decoded_type: matrix_type);
begin
  case AType of
  0:
    begin
      ASize := 2;
      decoded_type := M_INT; //* known to be true */
    end;
  1:
    begin
      ASize := 4;
      decoded_type := M_UINT; //* TODO: unknown ???? */
    end;
  2:
    begin
      ASize := 4;
      decoded_type := M_UINT; //* TODO: unknown ???? */
    end;
  3:
    begin
      ASize := 4;
      decoded_type := M_FLOAT; //* known to be true */
    end;
  5:
    begin
      ASize := 1;
      decoded_type := M_UINT; //* TODO: unknown ???? */
    end;
  6:
    begin
      ASize := 2;
      decoded_type := M_UINT; //* TODO: unknown ???? */
    end;
  else
//    x3f_printf(ERR, "Unknown matrix type (%ud)\n", type);
    Assert(False, Format('Unknown matrix type (%d)', [AType]));
  end;
end;

procedure get_matrix_copy(var entry: camf_entry);
var
  element_size, elements: Cardinal;
  i, _size: Integer;
begin
  element_size := entry.matrix_element_size;
  elements := entry.matrix_elements;

  if entry.matrix_decoded_type = M_FLOAT then
    _size := SizeOf(Double)
  else
    _size := SizeOf(Cardinal) * elements;

  GetMem(entry.matrix_decoded, _size);

  case element_size of
  4:
    case entry.matrix_decoded_type of
    M_INT, M_UINT:
      CopyMemory(entry.matrix_decoded, entry.matrix_data, _size);
    M_FLOAT:
      for i := 0 to elements - 1 do
      begin
	      PDouble(entry.matrix_decoded)^ := PSingle(entry.matrix_data)^;
        Inc(PDouble(entry.matrix_decoded));
        Inc(PSingle(entry.matrix_data));
      end
    else
//      x3f_printf(ERR, "Invalid matrix element type of size 4\n");
      Assert(False, 'Invalid matrix element type of size 4');
    end;
  2:
    case entry.matrix_decoded_type of
    M_INT:
      for i := 0 to elements - 1 do
      begin
	      PInteger(entry.matrix_decoded)^ := PSmallInt(entry.matrix_data)^;
        Inc(PInteger(entry.matrix_decoded));
        Inc(PSmallInt(entry.matrix_data));
      end;
    M_UINT:
      for i := 0 to elements - 1 do
      begin
	      PCardinal(entry.matrix_decoded)^ := PSmallInt(entry.matrix_data)^;
        Inc(PCardinal(entry.matrix_decoded));
        Inc(PSmallInt(entry.matrix_data));
      end
    else
//      x3f_printf(ERR, "Invalid matrix element type of size 2\n");
      Assert(False, 'Invalid matrix element type of size 2');
    end;
  1:
    case entry.matrix_decoded_type of
    M_INT:
      for i := 0 to elements - 1 do
      begin
	      PInteger(entry.matrix_decoded)^ := PShortInt(entry.matrix_data)^;
        Inc(PInteger(entry.matrix_decoded));
        Inc(PShortInt(entry.matrix_data));
      end;
    M_UINT:
      for i := 0 to elements - 1 do
      begin
	      PCardinal(entry.matrix_decoded)^ := PByte(entry.matrix_data)^;
        Inc(PCardinal(entry.matrix_decoded));
        Inc(PByte(entry.matrix_data));
      end
    else
//      x3f_printf(ERR, "Invalid matrix element type of size 1\n");
      Assert(False, 'Invalid matrix element type of size 1');
    end;
  else
//    x3f_printf(ERR, "Unknown size %d\n", element_size);
    Assert(False, Format('Unknown size %d', [element_size]));
  end;
end;

procedure x3f_setup_camf_matrix_entry(entry: Pcamf_entry);
var
  i, totalsize: Integer;
  e, v: PByte;
  _type, dim, off, _size: Cardinal;
  dentry: Pcamf_dim_entry;
begin
  totalsize := 1;

  e := entry.entry;
  v := entry.value_address;
  entry.matrix_type := (v + 0)^;
  _type := entry.matrix_type;
  entry.matrix_dim := (v + 4)^;
  dim := entry.matrix_dim;
  entry.matrix_data_off := (v + 8)^;
  off := entry.matrix_data_off;
  GetMem(entry.matrix_dim_entry, dim * SizeOf(camf_dim_entry));
  dentry := entry.matrix_dim_entry;

  for i := 0 to dim - 1 do
  begin
    dentry.size := (v + 12 + 12*i + 0)^;
    _size := dentry.size;
    dentry.name_offset := (v + 12 + 12*i + 4)^;
    dentry.n := (v + 12 + 12*i + 8)^;
    dentry.name := PAnsiChar(e + dentry.name_offset);
(*
    if (dentry[i].n != i) {
      /* TODO: is something needed to be made in this case */
      x3f_printf(DEBUG,
		 "Matrix entry for %s/%s is out of order "
		 "(index/%d != order/%d)\n",
		 entry->name_address, dentry[i].name, dentry[i].n, i);
    }
*)
    Inc(dentry);

    totalsize := totalsize * _size;
  end;

  set_matrix_element_info(_type, entry.matrix_element_size, entry.matrix_decoded_type);
  entry.matrix_data := (e + off);

  entry.matrix_elements := totalsize;
  entry.matrix_used_space := entry.entry_size - off;

  //* This estimate only works for matrices above a certain size */
  entry.matrix_estimated_element_size := entry.matrix_used_space / totalsize;

  get_matrix_copy(entry^);
end;

procedure x3f_setup_camf_entries(CAMF: Px3f_camf_t);
var
  p, _end: PByte;
  _entry: Pcamf_entry;
  i: Integer;
  p4: PCardinal;
begin
  p := CAMF.decoded_data;
  _end := p + CAMF.decoded_data_size;
  _entry := nil;

//  x3f_printf(DEBUG, "SETUP CAMF ENTRIES\n");

  i := 0;
  while p < _end do
  begin
    p4 := PCardinal(p);

    case p4^ of
    X3F_CMbP,
    X3F_CMbT,
    X3F_CMbM:
      ;
    else
//      x3f_printf(ERR, "Unknown CAMF entry %x @ %p\n", *p4, p4);
//      x3f_printf(ERR, "  start = %p end = %p\n", CAMF->decoded_data, end);
//      x3f_printf(ERR, "  left = %ld\n", (long)(end - p));
//      x3f_printf(ERR, "Stop parsing CAMF\n");
      //* TODO: Shouldn't this be treated as a fatal error? */
      break;
    end;

    //* TODO: lots of realloc - may be inefficient */
    _entry := ReallocMemory(_entry, (i + 1) * SizeOf(camf_entry));

    //* Pointer */
    Inc(_entry, i);
    _entry.entry := p;

    //* Header */
    _entry.id := p4^;
    Inc(p4);
    _entry.version := p4^;
    Inc(p4);
    _entry.entry_size := p4^;
    Inc(p4);
    _entry.name_offset := p4^;
    Inc(p4);
    _entry.value_offset := p4^;
    Inc(p4);

    //* Compute adresses and sizes */
    _entry.name_address := PAnsiChar(p + _entry.name_offset);
    _entry.value_address := p + _entry.value_offset;
    _entry.name_size := _entry.value_offset - _entry.name_offset;
    _entry.value_size := _entry.entry_size - _entry.value_offset;

    _entry.text_size := 0;
    _entry.text := nil;
    _entry.property_num := 0;
    _entry.property_name := nil;
    _entry.property_value := nil;
    _entry.matrix_type := 0;
    _entry.matrix_dim := 0;
    _entry.matrix_data_off := 0;
    _entry.matrix_data := nil;
    _entry.matrix_dim_entry := nil;

    _entry.matrix_decoded := nil;

    case _entry.id of
    X3F_CMbP:
      x3f_setup_camf_property_entry(_entry);
    X3F_CMbT:
      x3f_setup_camf_text_entry(_entry);
    X3F_CMbM:
      x3f_setup_camf_matrix_entry(_entry);
    end;

    Inc(p, _entry.entry_size);
    Inc(i);
  end;

  CAMF.entry_table.size := i;
  CAMF.entry_table.element := _entry;

//  x3f_printf(DEBUG, "SETUP CAMF ENTRIES (READY) Found %d entries\n", i);
end;

procedure x3f_load_camf_decode_type2(CAMF: Px3f_camf_t);
var
  i: Integer;
  key, tmp: Cardinal;
  old, new: Byte;
begin
  key := CAMF.t2.crypt_key;

  CAMF.decoded_data_size := CAMF.data_size;
  GetMem(CAMF.decoded_data, CAMF.decoded_data_size);

  for i := 0 to CAMF.data_size - 1 do
  begin
    old := PByte(CAMF.data)[i];
    key := (key * 1597 + 51749) mod 244944;
    tmp := key * (Int64(301593171) shr 24);
    new := old xor (((((key shl 8) - tmp) shr 1) + tmp) shr 17);
    PByte(CAMF.decoded_data)[i] := new;
  end;
end;

{ NOTE: the unpacking in this code is in big respects identical to
   true_decode_one_color(). The difference is in the output you
   build. It might be possible to make some parts shared. NOTE ALSO:
   This means that the meta data is obfuscated using an image
   compression algorithm. }

procedure camf_decode_type4(CAMF: Px3f_camf_t);
var
  seed, dst_size, rows, cols: Cardinal;
  row, col, diff, prev, _value: Integer;
  dst, dst_end: PByte;
  odd_dst, odd_row, odd_col: Boolean;
  _tree: Px3f_hufftree;
  BS: bit_state;
  row_start_acc: array [Boolean, Boolean] of Integer;
  acc: array[Boolean] of Integer;
begin
  seed := CAMF.t4.decode_bias;

  dst_size := CAMF.t4.decoded_data_size;

  odd_dst := False;

  _tree := @(CAMF.tree);

  rows := CAMF.t4.block_count;
  cols := CAMF.t4.block_size;

  CAMF.decoded_data_size := dst_size;

  GetMem(CAMF.decoded_data, CAMF.decoded_data_size);
  ZeroMemory(CAMF.decoded_data, CAMF.decoded_data_size);

  dst := CAMF.decoded_data;
  dst_end := dst + dst_size;

  set_bit_state(BS, CAMF.decoding_start);

  row_start_acc[False, False] := seed;
  row_start_acc[False, True] := seed;
  row_start_acc[True, False] := seed;
  row_start_acc[True, True] := seed;

  for row := 0 to rows - 1 do
  begin
    odd_row := Odd(row);

    { We loop through all the columns and the rows. But the actual
       data is smaller than that, so we break the loop when reaching
       the end. }
    for col := 0 to cols - 1 do
    begin
      odd_col := Odd(col);
      diff := get_true_diff(BS, _tree);

      if col < 2 then
        prev := row_start_acc[odd_row, odd_col]
      else
        prev := acc[odd_col];

      _value := prev + diff;

      acc[odd_col] := _value;
      if col < 2 then
	      row_start_acc[odd_row, odd_col] := _value;

      if odd_dst then
      begin
        dst^ := dst^ or (_value shr 8) and $0F;
        Inc(dst);

        if dst >= dst_end then
          Exit;

        dst^ := _value and $FF;
        Inc(dst);

        if dst >= dst_end then
          Exit;
      end
      else
        begin
	        dst^ := (_value shr 4) and $FF;
          Inc(dst);

	        if dst >= dst_end then
	          Exit;

	        dst^ := (_value shl 4) and $F0;
        end;

      odd_dst := not odd_dst;
    end; //* end col */
  end;   //* end row */
end;

procedure x3f_load_camf_decode_type4(CAMF: Px3f_camf_t);
var
  i: Integer;
  p: PByte;
  _element, _tmp: Px3f_true_huffman_element;
const
  //* TODO: where does the values 28 and 32 come from? */
  CAMF_T4_DATA_SIZE_OFFSET = 28;
  CAMF_T4_DATA_OFFSET = 32;
begin
  _element := nil;

  p := CAMF.data;
  i := 0;
  while p^ <> 0 do
  begin
    //* TODO: Is this too expensive ??*/
    _element := ReallocMemory(_element, (i + 1) * SizeOf(_element^));
    _tmp := _element;
    Inc(_tmp, i);

    _tmp.code_size := p^;
    Inc(p);
    _tmp.code := p^;
    Inc(p);

    Inc(i);
  end;

  CAMF.table.size := i;
  CAMF.table.element := _element;

  CAMF.decoding_size := PByte(PByte(CAMF.data) + CAMF_T4_DATA_SIZE_OFFSET)^;
  CAMF.decoding_start := PByte(CAMF.data) + CAMF_T4_DATA_OFFSET;

  //* TODO: can it be fewer than 8 bits? Maybe taken from TRU->table? */
  new_huffman_tree(@(CAMF.tree), 8);

  populate_true_huffman_tree(CAMF.tree, CAMF.table);
(*
#ifdef DBG_PRNT
  print_huffman_tree(CAMF->tree.nodes, 0, 0);
#endif
*)
  camf_decode_type4(CAMF);
end;

procedure camf_decode_type5(CAMF: Px3f_camf_t);
var
  acc, i, diff: Integer;
  dst: PByte;
  tree: Px3f_hufftree;
  BS: bit_state;
begin
  acc := CAMF.t5.decode_bias;

  tree := @(CAMF.tree);

  CAMF.decoded_data_size := CAMF.t5.decoded_data_size;
  GetMem(CAMF.decoded_data, CAMF.decoded_data_size);

  dst := CAMF.decoded_data;

  set_bit_state(BS, CAMF.decoding_start);

  for i := 0 to CAMF.decoded_data_size - 1 do
  begin
    diff := get_true_diff(BS, tree);

    acc := acc + diff;
    dst^ := acc and $FF;
    Inc(dst);
  end;
end;

procedure x3f_load_camf_decode_type5(CAMF: Px3f_camf_t);
var
  i: Integer;
  p: PByte;
  _element, _tmp: Px3f_true_huffman_element;
const
  //* TODO: where does the values 28 and 32 come from? */
  CAMF_T5_DATA_SIZE_OFFSET = 28;
  CAMF_T5_DATA_OFFSET = 32;
begin
  _element := nil;

  p := CAMF.data;
  i := 0;
  while p^ <> 0 do
  begin
    //* TODO: Is this too expensive ??*/
    _element := ReallocMemory(_element, (i + 1) * SizeOf(_element^));
    _tmp := _element;
    Inc(_tmp, i);

    _tmp.code_size := p^;
    Inc(p);
    _tmp.code := p^;
    Inc(p);

    Inc(i);
  end;

  CAMF.table.size := i;
  CAMF.table.element := _element;

  CAMF.decoding_size := PByte(PByte(CAMF.data) + CAMF_T5_DATA_SIZE_OFFSET)^;
  CAMF.decoding_start := PByte(CAMF.data) + CAMF_T5_DATA_OFFSET;

  //* TODO: can it be fewer than 8 bits? Maybe taken from TRU->table? */
  new_huffman_tree(@(CAMF.tree), 8);

  populate_true_huffman_tree(CAMF.tree, CAMF.table);

(*
#ifdef DBG_PRNT
  print_huffman_tree(CAMF->tree.nodes, 0, 0);
#endif
*)
  camf_decode_type5(CAMF);
end;

procedure x3f_load_camf(I: Px3f_info; DE: Px3f_directory_entry);
var
  DEH: Px3f_directory_entry_header;
  CAMF: Px3f_camf_t;
begin
  DEH := @(DE.header);
  CAMF := @(DEH.data_subsection.camf);

//  x3f_printf(DEBUG, "Loading CAMF of type %d\n", CAMF->type);

  read_data_set_offset(I, DE, X3F_CAMF_HEADER_SIZE);

  CAMF.data_size := read_data_block(CAMF.data, I, DE, 0);

  case CAMF.&type of
  2:			//* Older SD9-SD14 */
    x3f_load_camf_decode_type2(CAMF);
  4:			//* TRUE ... Merrill */
    x3f_load_camf_decode_type4(CAMF);
  5:			//* Quattro ... */
    x3f_load_camf_decode_type5(CAMF);
  else
    //* TODO: Shouldn't this be treated as a fatal error? */
//    x3f_printf(ERR, "Unknown CAMF type\n");
  end;

  if CAMF.decoded_data <> nil then
    x3f_setup_camf_entries(CAMF);
{  else
    //* TODO: Shouldn't this be treated as a fatal error? */
    x3f_printf(ERR, "No decoded CAMF data\n");}
end;

function x3f_load_data(_x3f: Px3f; DE: Px3f_directory_entry): x3f_return;
var
  I: Px3f_info;
begin
  Result := X3F_OK;

  I := @(_x3f.info);

  if Assigned(DE) then
  begin
    case DE.header.identifier of
    X3F_SECp:
      x3f_load_property_list(I, DE);
    X3F_SECi:
      x3f_load_image(I, DE);
    X3F_SECc:
      x3f_load_camf(I, DE);
    else
      begin
//        x3f_printf(ERR, "Unknown directory entry type\n");
        Result := (X3F_INTERNAL_ERROR);
      end;
    end;
  end
  else
    Result := X3F_INTERNAL_ERROR;
end;

end.
