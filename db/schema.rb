# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_09_26_131833) do

  create_table "answer_placeholder_embeddings", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "answer_id"
    t.bigint "placeholder_id"
    t.index ["answer_id"], name: "index_answer_placeholder_embeddings_on_answer_id"
    t.index ["placeholder_id"], name: "index_answer_placeholder_embeddings_on_placeholder_id"
  end

  create_table "answers", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "knowledge_basis_id"
    t.text "text"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "off_topic", default: false
    t.index ["created_by"], name: "index_answers_on_created_by"
    t.index ["knowledge_basis_id"], name: "index_answers_on_knowledge_basis_id"
  end

  create_table "custom_loggers", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "completed_at"
    t.string "namespace"
    t.text "scope"
    t.text "error_messages"
    t.text "objects"
    t.string "links"
    t.integer "alert_level", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "message"
    t.index ["completed_at"], name: "index_custom_loggers_on_completed_at"
    t.index ["created_at"], name: "index_custom_loggers_on_created_at"
    t.index ["namespace"], name: "index_custom_loggers_on_namespace"
    t.index ["started_at"], name: "index_custom_loggers_on_started_at"
  end

  create_table "external_api_connection_placeholder_embeddings", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "external_api_connection_id"
    t.integer "placeholder_id"
    t.index ["external_api_connection_id", "placeholder_id"], name: "api_placeholder_embeddings", unique: true
  end

  create_table "external_api_connections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "response_template"
    t.integer "knowledge_basis_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "oauth2_token_url"
    t.string "oauth2_scope"
    t.string "oauth2_client_id"
    t.string "encrypted_oauth2_client_secret"
    t.string "encrypted_oauth2_client_secret_iv"
  end

  create_table "global_values", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.integer "knowledge_basis_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "knowledge_bases", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "welcome_message"
    t.string "verify_token"
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "classifier", default: "fast_text"
    t.float "threshold", default: 0.2
    t.string "feedback_question", default: "Was this answer helpful?"
    t.string "language_code"
    t.boolean "allow_anonymous_access", default: false
    t.string "hash_id"
    t.string "widget_input_placeholder_text", default: "Ask a question ..."
    t.string "widget_submit_button_text", default: "Send"
    t.boolean "allow_facebook_messenger_access"
    t.text "widget_css"
    t.text "waiting_message"
    t.string "request_for_user_value_message", default: "What is your [[user_value]]?"
    t.index ["classifier"], name: "index_knowledge_bases_on_classifier"
  end

  create_table "knowledge_bases_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "knowledge_basis_id", null: false
    t.bigint "user_id", null: false
    t.index ["knowledge_basis_id", "user_id"], name: "index_knowledge_bases_users_on_knowledge_basis_id_and_user_id"
    t.index ["user_id", "knowledge_basis_id"], name: "index_knowledge_bases_users_on_user_id_and_knowledge_basis_id"
  end

  create_table "placeholders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "knowledge_basis_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "replaceable_type"
    t.integer "replaceable_id"
    t.index ["replaceable_type", "replaceable_id"], name: "index_placeholders_on_replaceable_type_and_replaceable_id"
  end

  create_table "questions", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "text"
    t.integer "answer_id"
    t.float "probability"
    t.integer "assigned_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmed_at"
    t.datetime "replied_at"
    t.integer "user_session_id"
    t.integer "knowledge_basis_id"
    t.index ["answer_id"], name: "index_questions_on_answer_id"
    t.index ["assigned_by"], name: "index_questions_on_assigned_by"
    t.index ["probability"], name: "index_questions_on_probability"
    t.index ["user_session_id"], name: "index_questions_on_user_session_id"
  end

  create_table "user_sessions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "questioner_id"
    t.string "questioner_name"
    t.integer "knowledge_basis_id"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "answer_id"
    t.index ["knowledge_basis_id"], name: "index_user_sessions_on_knowledge_basis_id"
    t.index ["questioner_id"], name: "index_user_sessions_on_questioner_id"
  end

  create_table "user_values", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "data_type"
    t.integer "knowledge_basis_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "regular_expression"
    t.string "prompt"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
