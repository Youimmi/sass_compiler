#include <string.h>
#include <unistd.h>
#include <limits.h>
#include "sass.h"
#include <stdio.h>
#include "erl_nif.h"

static inline ERL_NIF_TERM make_atom(ErlNifEnv* env, const char* name)
{
  ERL_NIF_TERM ret;
  if(enif_make_existing_atom(env, name, &ret, ERL_NIF_LATIN1)) {
    return ret;
  }
  return enif_make_atom(env, name);
}
// create tuple used to return compiled sass results
static inline ERL_NIF_TERM make_tuple(ErlNifEnv* env, const char* mesg, const char* atom_string)
{
  int output_len = sizeof(char) * strlen(mesg);
  ErlNifBinary output_binary;
  enif_alloc_binary(output_len, &output_binary);
  strncpy((char*)output_binary.data, mesg, output_len);
  ERL_NIF_TERM atom = make_atom(env, atom_string);
  ERL_NIF_TERM str = enif_make_binary(env, &output_binary);
  return enif_make_tuple2(env, atom, str);
}
// Size of elixir charlist string
static int my_enif_list_size(ErlNifEnv* env, ERL_NIF_TERM list)
{
  ERL_NIF_TERM head, tail, nexttail;
  int size = 0;
  tail = list;
  while(enif_get_list_cell(env, tail, &head, &nexttail))
  {
    tail = nexttail;
    size = size+1;
  }
  return size;
}
// converts a Elixir charlist into a c string
static char* my_enif_get_string(ErlNifEnv *env, ERL_NIF_TERM list)
{
  char *buf;
  int size=my_enif_list_size(env, list);

  if (!(buf = (char*) enif_alloc(size+1)))
  {
    return NULL;
  }
  if (enif_get_string(env, list, buf, size+1, ERL_NIF_LATIN1)<1)
  {
    enif_free(buf);
    return NULL;
  }
  return buf;
}

// Get atom name as a string.
char* get_atom_string(ErlNifEnv *env, ERL_NIF_TERM atom) {
        unsigned atom_size = 0;
        char *string = NULL;
        enif_get_atom_length(env, atom, &atom_size, ERL_NIF_LATIN1);
        string = (char*)enif_alloc(sizeof(char) * (atom_size + 1));
        if(!enif_get_atom(env, atom, string, (atom_size + 1), ERL_NIF_LATIN1)) {
            enif_free(string);
        }

        return string;
}

// Get a boolean true or false from there atom representations
bool get_bool_from_atom(ErlNifEnv *env, ERL_NIF_TERM atom) {

        char *_bool = get_atom_string(env, atom);
        if (strcmp(_bool, "true") == 0) {
            enif_free(_bool);
            return true;
        }
        enif_free(_bool);
        return false;
}



// Sass Options
/*void sass_option_set_input_path (struct Sass_Options* options, const char* input_path);*/
/*void sass_option_set_output_path (struct Sass_Options* options, const char* output_path);*/
/*void sass_option_set_plugin_path (struct Sass_Options* options, const char* plugin_path);*/
/*void sass_option_set_include_path (struct Sass_Options* options, const char* include_path);*/
/*void sass_option_set_source_map_file (struct Sass_Options* options, const char* source_map_file);*/
/*void sass_option_set_source_map_root (struct Sass_Options* options, const char* source_map_root);*/
/*void sass_option_set_c_functions (struct Sass_Options* options, Sass_C_Function_List c_functions);*/
/*void sass_option_set_importer (struct Sass_Options* options, Sass_C_Import_Callback importer);*/

#define SASS_OUTPUT_STYLE "output_style"
#define SASS_PRECISION "precision"
#define SASS_SOURCE_COMMENTS "source_comments"
#define SASS_SOURCE_MAP_EMBED "source_map_embed"
#define SASS_SOURCE_MAP_CONTENTS "source_map_contents"
#define SASS_OMIT_SOURCE_MAP_URL "omit_source_map_url"
#define SASS_IS_INDENTED_SYNTAX "is_indented_syntax"
#define SASS_INDENT "indent"
#define SASS_LINEFEED "linefeed"
#define SASS_INCLUDE_PATHS "include_paths"

#define SASS_INDENT_SPACE "  "
#define SASS_INDENT_TAB "\t"
#define SASS_INDENT_TAB_ATOM "tab"

#define SASS_UNIX_LINEFEED "\n"
#define SASS_WINDOWS_LINEFEED "\r\n"
#define SASS_LINEFEED_WINDOWS "windows"
#define SASS_LINEFEED_UNIX "unix"


// This function parses and sets sass optiosn on the sass contenxt
// Note not all options are implimented at this time see the constant definitions above
struct Sass_Options* parse_sass_options(ErlNifEnv *env, Sass_Context *context, ERL_NIF_TERM map) {
    ERL_NIF_TERM key, value;

    struct Sass_Options* options = sass_context_get_options(context);

    if(!enif_is_map(env, map)) {
        ERL_NIF_TERM exception = enif_make_string(env, "(Argument Error) 2nd argumanet must be a map", ERL_NIF_LATIN1);
        enif_raise_exception(env, exception);
    }
    // output style
    key = make_atom(env, SASS_OUTPUT_STYLE);
    if (enif_get_map_value(env, map, key, &value)) {
        int output_style;
        enif_get_int(env, value, &output_style);
        sass_option_set_output_style(options, (Sass_Output_Style)output_style);
    }
    // precision
    key = make_atom(env, SASS_PRECISION);
    if (enif_get_map_value(env, map, key, &value)) {
        int precision;
        enif_get_int(env, value, &precision);
        sass_option_set_precision(options, precision);
    }
    // source comments
    key = make_atom(env, SASS_SOURCE_COMMENTS);
    if (enif_get_map_value(env, map, key, &value)) {
        sass_option_set_source_comments(options, get_bool_from_atom(env, value));
    }
    // source map embed
    key = make_atom(env, SASS_SOURCE_MAP_EMBED);
    if (enif_get_map_value(env, map, key, &value)) {
        sass_option_set_source_map_embed(options, get_bool_from_atom(env, value));
    }
    // source map contents
    key = make_atom(env, SASS_SOURCE_MAP_CONTENTS);
    if (enif_get_map_value(env, map, key, &value)) {
        sass_option_set_source_map_contents(options, get_bool_from_atom(env, value));
    }
    // omit source map url
    key = make_atom(env, SASS_OMIT_SOURCE_MAP_URL);
    if (enif_get_map_value(env, map, key, &value)) {
        sass_option_set_omit_source_map_url(options, get_bool_from_atom(env, value));
    }
    // is indented syntax
    key = make_atom(env, SASS_IS_INDENTED_SYNTAX);
    if (enif_get_map_value(env, map, key, &value)) {
        sass_option_set_is_indented_syntax_src(options, get_bool_from_atom(env, value));
    }
    // indent
    key = make_atom(env, SASS_INDENT);
    if (enif_get_map_value(env, map, key, &value)) {
        if (strcmp(get_atom_string(env, value), SASS_INDENT_TAB_ATOM) == 0) {
            sass_option_set_linefeed(options, SASS_INDENT_TAB);
        } else {
            sass_option_set_linefeed(options, SASS_INDENT_SPACE);
        }
    }
    // linefeed
    key = make_atom(env, SASS_LINEFEED);
    if (enif_get_map_value(env, map, key, &value)) {
        char *val = get_atom_string(env, value);
        if (strcmp(val, SASS_LINEFEED_WINDOWS) == 0) {
            sass_option_set_indent(options, SASS_WINDOWS_LINEFEED);
        } else if (strcmp(val, SASS_LINEFEED_UNIX)){
            sass_option_set_indent(options, SASS_UNIX_LINEFEED);
        } else {
            ERL_NIF_TERM exception = enif_make_string(env, "(Argument Error) linefeed must be ':unix' or ':windows'", ERL_NIF_LATIN1);
            enif_raise_exception(env, exception);
        }
    }
    // include paths
    key = make_atom(env, SASS_INCLUDE_PATHS);
    if (enif_get_map_value(env, map, key, &value)) {
        ERL_NIF_TERM head;
        if (!enif_is_list(env, value)) {
            ERL_NIF_TERM exception = enif_make_string(env, "(Argument Error) include_paths must be a list", ERL_NIF_LATIN1);
            enif_raise_exception(env, exception);
        }
        while(!enif_is_empty_list(env, value)) {
            char *path;
            enif_get_list_cell(env, value, &head, &value);
            if (enif_is_binary(env, head)) {
                ErlNifBinary bin;
                enif_inspect_binary(env, head, &bin);
                path = (char*)enif_alloc(strlen((const char*)bin.data) + 1);
                strcpy(path, (const char *)bin.data);
                path[bin.size] = '\0';
                sass_option_push_include_path(options, path);
                enif_free(path);
            } else if(enif_is_list(env, head)) {
                path = my_enif_get_string(env, head);
                sass_option_push_include_path(options, path);
                enif_free(path);
            }
        };
    }

    return options;
}

// NIF for compiling a sass string arguments are
// * string sass_string
// * Map sass_options
static ERL_NIF_TERM sass_compile_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ERL_NIF_TERM ret;

  if (argc > 2) {
    return enif_make_badarg(env);
  }

  char *sass_string;

  if(enif_is_binary(env, argv[0])) {
      ErlNifBinary bin;
      enif_inspect_binary(env, argv[0], &bin);
      sass_string = (char*)malloc(strlen((const char*)bin.data) + 1);
      strcpy(sass_string, (const char *)bin.data);
      sass_string[bin.size] = '\0';
  } else if(enif_is_list(env, argv[0])) {
      sass_string = (char*)malloc(my_enif_list_size(env, argv[0]));
      strcpy(sass_string, my_enif_get_string(env, argv[0]));
  } else {
      return enif_make_badarg(env);
  }

  struct Sass_Data_Context* ctx = sass_make_data_context(sass_string);
  struct Sass_Context* ctx_out = sass_data_context_get_context(ctx);
  struct Sass_Options* options = parse_sass_options(env, ctx_out, argv[1]);

  sass_data_context_set_options(ctx, options);

  sass_compile_data_context(ctx);

  int error_status = sass_context_get_error_status(ctx_out);
  const char *error_message = sass_context_get_error_message(ctx_out);
  const char *output_string = sass_context_take_output_string(ctx_out);

  if (error_status) {
    if (error_message) {
      ret = make_tuple(env, error_message, "error");
    } else {
      ret = make_tuple(env, "An error occured; no error message available.", "error");
    }
  } else if (output_string) {
    ret = make_tuple(env, output_string, "ok");
  } else {
    ret = make_tuple(env, "Unknown internal error.", "error");
  }
  // this will also free sass_string
  sass_delete_data_context(ctx);

  return ret;
}
// NIF for compiling a sass file arguments are
// * string filename
// * Map sass_options
static ERL_NIF_TERM sass_compile_file_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ERL_NIF_TERM ret;
  if (argc > 2) {
    return enif_make_badarg(env);
  }

  char *sass_file;

  if(enif_is_binary(env, argv[0])) {
    ErlNifBinary bin;
    enif_inspect_binary(env, argv[0], &bin);
    sass_file = (char*)malloc(strlen((const char*)bin.data) + 1);
    strcpy(sass_file, (const char *)bin.data);
    sass_file[bin.size] = '\0';
  } else if(enif_is_list(env, argv[0])) {
    sass_file = (char*)malloc(my_enif_list_size(env, argv[0]));
    strcpy(sass_file, my_enif_get_string(env, argv[0]));
  } else {
    return enif_make_badarg(env);
  }

  // create the file context and get all related structs
  struct Sass_File_Context* file_ctx = sass_make_file_context(sass_file);
  struct Sass_Context* ctx = sass_file_context_get_context(file_ctx);
  struct Sass_Options* options = parse_sass_options(env, ctx, argv[1]);


  sass_file_context_set_options(file_ctx, options);

  int error_status = sass_compile_file_context(file_ctx);

  const char *error_message = sass_context_get_error_message(ctx);
  const char *output_string = sass_context_get_output_string(ctx);

  if (error_status) {
    if (error_message) {
      ret = make_tuple(env, error_message, "error");
    } else {
      ret = make_tuple(env, "An error occured; no error message available.", "error");
    }
  } else if (output_string) {
    ret = make_tuple(env, output_string, "ok");
  } else {
    ret = make_tuple(env, "Unknown internal error.", "error");
  }
  //this will also free sass_file
  sass_delete_file_context(file_ctx);

  return ret;
}

static ERL_NIF_TERM sass_version(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  const char *version = libsass_version();
  int output_len = sizeof(char) * strlen(version);
  ErlNifBinary output_binary;
  enif_alloc_binary(output_len, &output_binary);
  strncpy((char*)output_binary.data, version, output_len);
  ERL_NIF_TERM str = enif_make_binary(env, &output_binary);
  return str;

}

static ErlNifFunc nif_funcs[] = {
  { "compile", 2, sass_compile_nif, 0 },
  { "compile_file", 2, sass_compile_file_nif, 0 },
  { "version", 0, sass_version, 0 }
};

ERL_NIF_INIT(Elixir.Sass.Compiler, nif_funcs, NULL, NULL, NULL, NULL);
