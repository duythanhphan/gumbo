
#include <stdlib.h>
#include <string.h>

#include <fstream>
#include <iostream>
#include <string>

#include "gumbo.h"

static std::string get_text(GumboNode* node) {
  if (node->type == GUMBO_NODE_TEXT) {
    return std::string(node->v.text.text);
  }
  return std::string();
}

static void search_for_entries(GumboNode* node, std::string &str, int &found) {
  if (node->type != GUMBO_NODE_ELEMENT) {
    return;
  }

  GumboAttribute *_id, *_class;
  if (node->v.element.tag == GUMBO_TAG_DIV &&
      (_id = gumbo_get_attribute(&node->v.element.attributes, "id")) &&
      (_class = gumbo_get_attribute(&node->v.element.attributes, "class")) &&
      !strcmp(_id->value, "project_table_static_info") &&
      !strcmp(_class->value, "dataTables_info")) {
    GumboVector* children = &node->v.element.children;
    for (int i = 0; i < children->length; ++i) {
      str = get_text(static_cast<GumboNode*>(children->data[i]));
      found = 1;
      return;
    }
  }

  GumboVector* children = &node->v.element.children;
  for (int i = 0; i < children->length; ++i) {
    search_for_entries(static_cast<GumboNode*>(children->data[i]), str, found);
    // return after found entry
    if (found == 1) {
      return;
    }
  }

  return;
}

int main(int argc, char** argv) {
  if (argc != 2) {
    std::cout << "Usage: find_links <html filename>.\n";
    exit(EXIT_FAILURE);
  }
  const char* filename = argv[1];

  std::ifstream in(filename, std::ios::in | std::ios::binary);
  if (!in) {
    std::cout << "File " << filename << " not found!\n";
    exit(EXIT_FAILURE);
  }

  std::string contents;
  in.seekg(0, std::ios::end);
  contents.resize(in.tellg());
  in.seekg(0, std::ios::beg);
  in.read(&contents[0], contents.size());
  in.close();

  GumboOutput* output = gumbo_parse(contents.c_str());

  std::string str("");
  int found = 0;
  search_for_entries(output->root, str, found);

  if (found == 1) {
    std::cout << str << std::endl;
  } else {
    std::cout << "Info:> Not Found!!!" << std::endl;
  }

  gumbo_destroy_output(&kGumboDefaultOptions, output);
}
