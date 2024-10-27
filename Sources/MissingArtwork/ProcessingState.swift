//
//  ProcessingState.swift
//
//
//  Created by Greg Bolsinga on 2/8/23.
//

import Foundation

public enum ProcessingState: Sendable {
  case none  // no action has been taken
  case processing  // the action is processing
  case success  // the action has succeeded
  case failure  // the action has failed.
}
