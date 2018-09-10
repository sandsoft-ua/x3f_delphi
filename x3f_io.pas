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
    element : ^uint16;
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
    data: ^uint16;		  //* Pointer to actual image data */
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
    data: ^uint8;		    //* Pointer to actual image data */
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
    text                          : ^byte;
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
  var
    size : uint32;
    element : Pcamf_entry;
  end;

  x3f_camf_typeN = record
  var
    val0, val1, val2, val3 : uint32;
  end;

  x3f_camf_type2 = record
  var
    reserved,
    infotype,
    infotype_version,
    crypt_key        : uint32;
  end;

  x3f_camf_type4 = record
  var
    decoded_data_size,
    decode_bias,
    block_size,
    block_count       : uint32;
  end;

  x3f_camf_type5 = record
  var
    decoded_data_size,
    decode_bias,
    unknown2,
    unknown3          : uint32;
  end;

  x3f_camf_t = record
  var
    &type             : uint32;
    tN                : x3f_camf_typeN;
    t2                : x3f_camf_type2;
    t4                : x3f_camf_type4;
    t5                : x3f_camf_type5;
    data              : pointer;
    data_size         : uint32;
    table             : x3f_true_huffman_table;
    tree              : x3f_hufftree;
    decoding_start    : ^byte;
    decoding_size     : uint32;
    decoded_data      : pointer;
    decoded_data_size : uint32;
    entry_table       : camf_entry_table;
  end;

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
procedure Get_Table4(AFileHandle: THandle; var ATable: x3f_table32; ANumber: Integer);
var
  i: Integer;
  _element: PCardinal;
begin
  ATable.size := ANumber;
  ReallocMemory(ATable.element, ANumber * SizeOf(ATable.element^));

  _element := ATable.element;
  for i := 0 to ANumber - 1 do
  begin
    ATable.element^ := x3f_get4(AFileHandle);
    Inc(ATable.element);
  end;

  ATable.element := _element;
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

    if Assigned(_t_next) then
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
begin
  TRU := ID.tru;
  Q := ID.quattro;
  uint32_t seed = TRU->seed[color]; /* TODO : Is this correct ? */
  int row;

  x3f_hufftree_t *tree = &TRU->tree;
  bit_state_t BS;

  int32_t row_start_acc[2][2];
  uint32_t rows = ID->rows;
  uint32_t cols = ID->columns;
  x3f_area16_t *area = &TRU->x3rgb16;
  uint16_t *dst = area->data + color;

  set_bit_state(&BS, TRU->plane_address[color]);

  row_start_acc[0][0] = seed;
  row_start_acc[0][1] = seed;
  row_start_acc[1][0] = seed;
  row_start_acc[1][1] = seed;

  if (ID->type_format == X3F_IMAGE_RAW_QUATTRO ||
      ID->type_format == X3F_IMAGE_RAW_SDQ ||
      ID->type_format == X3F_IMAGE_RAW_SDQH) {
    rows = Q->plane[color].rows;
    cols = Q->plane[color].columns;

    if (Q->quattro_layout && color == 2) {
      area = &Q->top16;
      dst = area->data;
    }
    x3f_printf(DEBUG, "Quattro decode one color (%d) rows=%d cols=%d\n",
	       color, rows, cols);
  } else {
    x3f_printf(DEBUG, "TRUE decode one color (%d) rows=%d cols=%d\n",
	       color, rows, cols);
  }

  assert(rows == area->rows && cols >= area->columns);

  for (row = 0; row < rows; row++) {
    int col;
    bool_t odd_row = row&1;
    int32_t acc[2];

    for (col = 0; col < cols; col++) {
      bool_t odd_col = col&1;
      int32_t diff = get_true_diff(&BS, tree);
      int32_t prev = col < 2 ?
	row_start_acc[odd_row][odd_col] :
	acc[odd_col];
      int32_t value = prev + diff;

      acc[odd_col] = value;
      if (col < 2)
	row_start_acc[odd_row][odd_col] = value;

      /* Discard additional data at the right for binned Quattro plane 2 */
      if (col >= area->columns) continue;

      *dst = value;
      dst += area->channels;
    }
  }
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
    x3f_load_huffman(I, DE, 10, 1, ID.row_stride);
  X3F_IMAGE_THUMB_PLAIN:
    x3f_load_pixmap(I, DE);
  X3F_IMAGE_THUMB_HUFFMAN:
    x3f_load_huffman(I, DE, 8, 0, ID.row_stride);
  X3F_IMAGE_THUMB_JPEG:
    x3f_load_jpeg(I, DE);
  else
    //* TODO: Shouldn't this be treated as a fatal error? */
//    x3f_printf(ERR, "Unknown image type\n");
  end;
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
