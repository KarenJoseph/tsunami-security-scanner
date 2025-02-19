/*
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.google.tsunami.plugin.payload;

import com.google.protobuf.ByteString;
import java.util.Optional;

/** Type used for functions which verify if a payload was executed */
@FunctionalInterface
public interface Validator {
  /**
   * Returns whether the associated payload was executed.
   *
   * @throws NoCallbackServerException if the implementation uses the callback server but Tsunami
   *     is not configured to use it.
   */
  boolean isExecuted(Optional<ByteString> input) throws NoCallbackServerException;
}
