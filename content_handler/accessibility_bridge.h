// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef FLUTTER_CONTENT_HANDLER_ACCESSIBILITY_BRIDGE_H_
#define FLUTTER_CONTENT_HANDLER_ACCESSIBILITY_BRIDGE_H_

#include <unordered_map>

#include "apps/maxwell/services/context/context_writer.fidl.h"
#include "flutter/lib/ui/semantics/semantics_node.h"
#include "lib/app/cpp/application_context.h"

namespace flutter_runner {

// Maintain an up-to-date list of SemanticsNodes on screen, and communicate
// with the Context Service.
class AccessibilityBridge {
 public:
  AccessibilityBridge(app::ApplicationContext* context);

  // Update the internal representation of the semantics nodes, and write the
  // semantics to Context Service.
  void UpdateSemantics(const std::vector<blink::SemanticsNode>& update);

 private:
  // Walk the semantics node tree starting at |id|, and store the id of each
  // visited child in |visited_nodes|.
  void UpdateVisitedForNodeAndChildren(const int id,
                                       std::vector<int>* visited_nodes);

  // Remove any node from |semantics_nodes_| that doesn't have an id in
  // |visited_nodes|.
  void EraseUnvisitedNodes(const std::vector<int>& visited_nodes);

  std::unordered_map<int, blink::SemanticsNode> semantics_nodes_;
  maxwell::ContextWriterPtr writer_;
};

}  // namespace flutter_runner

#endif  // FLUTTER_CONTENT_HANDLER_ACCESSIBILITY_BRIDGE_H_
